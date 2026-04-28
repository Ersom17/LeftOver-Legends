export default async ({ req, res, log, error }) => {
  try {
    const groqKey = process.env.GROQ_API_KEY;
    if (!groqKey) {
      return res.json({ ok: false, error: 'Missing GROQ_API_KEY' }, 500);
    }

    let body = {};
    try {
      if (req.bodyJson && typeof req.bodyJson === 'object') {
        body = req.bodyJson;
      } else if (typeof req.body === 'string' && req.body.trim()) {
        body = JSON.parse(req.body);
      }
    } catch (e) {
      log('Body parse error: ' + e.message);
    }

    const base64Image = typeof body.image === 'string' ? body.image.trim() : '';
    if (!base64Image) {
      return res.json({ ok: false, error: 'Missing image (base64)' }, 400);
    }

    log('Image received, length: ' + base64Image.length);

    const today = new Date().toISOString().slice(0, 10);

    const prompt = 'You are a grocery receipt parser. Look at this receipt image and extract all grocery items.\n\n'
      + 'Return ONLY a raw JSON object. No markdown. No explanation. No text before or after.\n\n'
      + 'Format:\n'
      + '{"items":[{"name":"string","category":"dairy|veggies|fruit|protein|grains|other","emoji":"string","estimatedExpirationDate":"ISO date","price":0.00,"currency":"CHF","quantity":"string or null","confidence":0.9,"sourceText":"string"}]}\n\n'
      + 'Rules:\n'
      + '- Only real grocery items (fridge/pantry). Ignore totals, taxes, store name, timestamps.\n'
      + '- Estimate expiry from today: ' + today + '\n'
      + '- Default currency CHF.\n'
      + '- Return the JSON object only, starting with { and ending with }';

    log('Calling Groq vision...');

    const groqResponse = await fetch('https://api.groq.com/openai/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': 'Bearer ' + groqKey,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'meta-llama/llama-4-scout-17b-16e-instruct',
        messages: [
          {
            role: 'user',
            content: [
              {
                type: 'image_url',
                image_url: { url: 'data:image/jpeg;base64,' + base64Image },
              },
              {
                type: 'text',
                text: prompt,
              },
            ],
          },
        ],
        temperature: 0.1,
        max_tokens: 1500,
      }),
    });

    const rawText = await groqResponse.text();
    log('Groq status: ' + groqResponse.status);

    if (!groqResponse.ok) {
      log('Groq error: ' + rawText);
      return res.json({ ok: false, error: 'Groq request failed', details: rawText }, 500);
    }

    let apiJson;
    try {
      apiJson = JSON.parse(rawText);
    } catch (e) {
      return res.json({ ok: false, error: 'Invalid JSON from Groq API', details: rawText }, 500);
    }

    let text = (apiJson.choices && apiJson.choices[0] && apiJson.choices[0].message && apiJson.choices[0].message.content) || '';
    log('Model response length: ' + text.length);
    log('Model raw (first 400): ' + text.substring(0, 400));

    if (!text) {
      return res.json({ ok: false, error: 'Empty model response', details: apiJson }, 500);
    }

    // Strip any markdown fences
    text = text.trim();
    text = text.replace(/^```json\s*/i, '').replace(/\s*```$/i, '').trim();
    text = text.replace(/^```\s*/, '').replace(/\s*```$/, '').trim();

    // Find outermost { ... } — handles any preamble text the model adds
    const start = text.indexOf('{');
    const end = text.lastIndexOf('}');
    if (start !== -1 && end > start) {
      text = text.substring(start, end + 1);
    }

    log('Extracted JSON candidate (first 400): ' + text.substring(0, 400));

    let parsed;
    try {
      parsed = JSON.parse(text);
    } catch (e) {
      log('JSON.parse failed: ' + e.message);
      return res.json({ ok: false, error: 'Model did not return valid JSON', raw: text }, 500);
    }

    const items = Array.isArray(parsed.items) ? parsed.items : [];
    log('Parsed ' + items.length + ' items');

    return res.json({ ok: true, items }, 200);

  } catch (err) {
    error(err.stack || err.message || String(err));
    return res.json({ ok: false, error: err.message || 'Unknown error' }, 500);
  }
};