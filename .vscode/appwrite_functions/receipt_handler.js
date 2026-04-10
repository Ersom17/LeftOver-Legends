export default async ({ req, res, log, error }) => {
  try {
    const hfToken = process.env.HF_TOKEN || req.env?.HF_TOKEN;
    const ocrKey = process.env.OCR_API_KEY || req.env?.OCR_API_KEY;

    if (!hfToken) {
      return res.json({ ok: false, error: 'Missing HF_TOKEN environment variable' }, 500);
    }
    if (!ocrKey) {
      return res.json({ ok: false, error: 'Missing OCR_API_KEY environment variable' }, 500);
    }

    // Parse body — bodyJson may be null if Content-Type header is missing
    let body = {};
    try {
      body = req.bodyJson ?? (req.body ? JSON.parse(req.body) : {});
    } catch (_) {
      body = {};
    }

    log(`Body keys: ${Object.keys(body).join(', ') || 'none'}`);

    const base64Image = typeof body.image === 'string' ? body.image.trim() : '';

    if (!base64Image) {
      return res.json({ ok: false, error: 'Missing image (base64)' }, 400);
    }

    // --- Step 1: OCR with ocr.space (free tier, no npm packages needed) ---
    log('Running OCR via ocr.space...');

    const ocrResponse = await fetch('https://api.ocr.space/parse/image', {
      method: 'POST',
      headers: {
        'apikey': ocrKey,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: new URLSearchParams({
        base64Image: `data:image/jpeg;base64,${base64Image}`,
        language: 'eng',
        isOverlayRequired: 'false',
        detectOrientation: 'true',
        scale: 'true',
        OCREngine: '2',
      }).toString(),
    });

    const ocrResult = await ocrResponse.json();

    if (ocrResult.IsErroredOnProcessing) {
      return res.json({ ok: false, error: `OCR failed: ${ocrResult.ErrorMessage}` }, 500);
    }

    const rawText = ocrResult.ParsedResults?.[0]?.ParsedText ?? '';
    log(`OCR extracted ${rawText.length} chars`);

    if (!rawText.trim()) {
      return res.json({ ok: false, error: 'No text found in image.' }, 400);
    }

    // --- Step 2: Parse items with Llama 3.1 8B ---
    const today = new Date().toISOString().slice(0, 10);

    const systemPrompt = `
You are a grocery receipt parser.
Always answer with valid JSON only.
Do not add markdown fences.
Do not add explanations.
`;

    const userPrompt = `
You receive OCR text extracted from a grocery receipt.

Return ONLY valid JSON in this exact format:

{
  "items": [
    {
      "name": "string",
      "category": "dairy|veggies|fruit|protein|grains|other",
      "emoji": "string",
      "estimatedExpirationDate": "ISO date string",
      "price": number|null,
      "currency": "CHF",
      "quantity": "string|null",
      "confidence": number,
      "sourceText": "string"
    }
  ]
}

Rules:
- Extract only real grocery items a user could store in a fridge or pantry.
- Ignore store name, address, totals, taxes, discounts, payment lines, loyalty data, timestamps, transaction IDs.
- Normalize OCR names into clean English product names with no line breaks.
- Guess category from the item name.
- Suggest a relevant emoji for each item.
- Estimate expiration date based on typical shelf life from today: ${today}.
- confidence is a number between 0 and 1.
- price is the line-item price when visible, otherwise null.
- currency defaults to "CHF" unless another currency is clearly visible.
- quantity is a short string like "1", "500g", "1L", or null.
- sourceText is the OCR fragment that produced this item.
- Return JSON only.

OCR TEXT:
${rawText}
`;

    const hfResponse = await fetch(
      'https://router.huggingface.co/v1/chat/completions',
      {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${hfToken}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model: 'meta-llama/Llama-3.1-8B-Instruct',
          messages: [
            { role: 'system', content: systemPrompt },
            { role: 'user', content: userPrompt },
          ],
          temperature: 0.2,
          max_tokens: 900,
        }),
      }
    );

    const rawApiResponse = await hfResponse.text();

    if (!hfResponse.ok) {
      log(`HF error status: ${hfResponse.status}`);
      log(rawApiResponse);
      return res.json(
        { ok: false, error: 'Hugging Face request failed', status: hfResponse.status, details: rawApiResponse },
        500
      );
    }

    let parsedApiResponse;
    try {
      parsedApiResponse = JSON.parse(rawApiResponse);
    } catch (e) {
      return res.json(
        { ok: false, error: 'Invalid JSON from Hugging Face API', details: rawApiResponse },
        500
      );
    }

    let generatedText = parsedApiResponse?.choices?.[0]?.message?.content ?? '';
    if (!generatedText) {
      return res.json(
        { ok: false, error: 'Unexpected Hugging Face response shape', details: parsedApiResponse },
        500
      );
    }

    generatedText = generatedText.trim();
    if (generatedText.startsWith('```json')) {
      generatedText = generatedText.replace(/^```json\s*/, '').replace(/\s*```$/, '').trim();
    } else if (generatedText.startsWith('```')) {
      generatedText = generatedText.replace(/^```\s*/, '').replace(/\s*```$/, '').trim();
    }

    let receiptJson;
    try {
      receiptJson = JSON.parse(generatedText);
    } catch (e) {
      log('Model raw content:');
      log(generatedText);
      return res.json(
        { ok: true, warning: 'Model returned text instead of clean JSON', raw: generatedText },
        200
      );
    }

    const items = Array.isArray(receiptJson.items) ? receiptJson.items : [];
    log(`Parsed ${items.length} item(s)`);

    return res.json({ ok: true, items }, 200);

  } catch (err) {
    error(err?.stack || err?.message || String(err));
    return res.json({ ok: false, error: err?.message || 'Unknown server error' }, 500);
  }
};
