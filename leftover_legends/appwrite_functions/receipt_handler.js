export default async ({ req, res, log, error }) => {
  try {
    const hfToken = process.env.HF_TOKEN;

    if (!hfToken) {
      return res.json({ ok: false, error: 'Missing HF_TOKEN' }, 500);
    }

    // Parse body
    let body = {};
    try {
      if (req.bodyJson && typeof req.bodyJson === 'object') {
        body = req.bodyJson;
      } else if (typeof req.body === 'string' && req.body.trim()) {
        body = JSON.parse(req.body);
      }
    } catch (e) {
      log(`Body parse error: ${e.message}`);
    }

    const base64Image = typeof body.image === 'string' ? body.image.trim() : '';

    if (!base64Image) {
      return res.json({ ok: false, error: 'Missing image (base64)' }, 400);
    }

    log(`Image received, length: ${base64Image.length}`);

    const today = new Date().toISOString().slice(0, 10);

    const prompt = `You are a grocery receipt parser. Look at this receipt image and extract all grocery items.

Return ONLY valid JSON with no markdown fences, no explanation, just the JSON:

{
  "items": [
    {
      "name": "string",
      "category": "dairy|veggies|fruit|protein|grains|other",
      "emoji": "string",
      "estimatedExpirationDate": "ISO date string",
      "price": number or null,
      "currency": "CHF",
      "quantity": "string or null",
      "confidence": number between 0 and 1,
      "sourceText": "string"
    }
  ]
}

Rules:
- Extract only real grocery items a person could store in a fridge or pantry.
- Ignore store name, address, totals, taxes, discounts, payment lines, timestamps.
- Use clean English product names.
- Estimate expiration date based on typical shelf life from today: ${today}.
- currency defaults to CHF unless clearly something else.
- Return JSON only, nothing else.`;

    log('Sending image to Llama Vision...');

    const hfResponse = await fetch(
      'https://router.huggingface.co/v1/chat/completions',
      {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${hfToken}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model: 'Qwen/Qwen2.5-VL-7B-Instruct',
          messages: [
            {
              role: 'user',
              content: [
                {
                  type: 'image_url',
                  image_url: {
                    url: `data:image/jpeg;base64,${base64Image}`,
                  },
                },
                {
                  type: 'text',
                  text: prompt,
                },
              ],
            },
          ],
          temperature: 0.1,
          max_tokens: 1000,
        }),
      }
    );

    const rawApiResponse = await hfResponse.text();
    log(`HF status: ${hfResponse.status}`);

    if (!hfResponse.ok) {
      log(`HF error: ${rawApiResponse}`);
      return res.json(
        { ok: false, error: 'Hugging Face request failed', details: rawApiResponse },
        500
      );
    }

    let parsedApiResponse;
    try {
      parsedApiResponse = JSON.parse(rawApiResponse);
    } catch (e) {
      return res.json(
        { ok: false, error: 'Invalid JSON from HF API', details: rawApiResponse },
        500
      );
    }

    let generatedText = parsedApiResponse?.choices?.[0]?.message?.content ?? '';
    log(`Model response length: ${generatedText.length}`);

    if (!generatedText) {
      return res.json(
        { ok: false, error: 'Empty response from model', details: parsedApiResponse },
        500
      );
    }

    // Strip markdown fences if model added them anyway
    generatedText = generatedText.trim();
    if (generatedText.startsWith('```json')) {
      generatedText = generatedText.replace(/^```json\s*/, '').replace(/\s*```$/, '').trim();
    } else if (generatedText.startsWith('```')) {
      generatedText = generatedText.replace(/^```\s*/, '').replace(/\s*```$/, '').trim();
    }

    // Extract JSON if model added surrounding text
    const jsonMatch = generatedText.match(/\{[\s\S]*\}/);
    if (jsonMatch) {
      generatedText = jsonMatch[0];
    }

    let receiptJson;
    try {
      receiptJson = JSON.parse(generatedText);
    } catch (e) {
      log(`Could not parse model output: ${generatedText}`);
      return res.json(
        { ok: false, error: 'Model did not return valid JSON', raw: generatedText },
        500
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
