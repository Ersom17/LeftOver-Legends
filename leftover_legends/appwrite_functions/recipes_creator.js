export default async ({ req, res, log, error }) => {
  try {
    const hfToken = process.env.HF_TOKEN || req.env?.HF_TOKEN;

    if (!hfToken) {
      return res.json({ ok: false, error: 'Missing HF_TOKEN environment variable' }, 500);
    }

    const body = req.bodyJson || {};
    const culture = typeof body.culture === 'string' ? body.culture.trim() : '';
    const items = Array.isArray(body.items) ? body.items : [];

    if (!culture) {
      return res.json({ ok: false, error: 'Missing culture' }, 400);
    }

    if (items.length === 0) {
      return res.json({ ok: false, error: 'No items provided' }, 400);
    }

    const normalizedItems = items
      .filter(item => item && typeof item.name === 'string')
      .map(item => ({
        name: item.name.trim(),
        expirationDate: item.expirationDate || null,
        priority: Number(item.priority) || 3,
      }))
      .sort((a, b) => a.priority - b.priority);

    const ingredientsText = normalizedItems
      .map(item => `- ${item.name} | priority: ${item.priority} | expirationDate: ${item.expirationDate ?? 'unknown'}`)
      .join('\n');

    const systemPrompt = `
You are a helpful cooking assistant.
Always answer with valid JSON only.
Do not add markdown fences.
`;

    const userPrompt = `
Create 3 practical recipe ideas inspired by ${culture} cuisine.

Use these ingredients, prioritizing the lowest priority number first.
Priority 1 means urgent: these ingredients expire the soonest and should be used first.
Priority 2 means medium urgency.
Priority 3 means low urgency.

Available ingredients:
${ingredientsText}

Rules:
- The FIRST recipe must use ONLY the available ingredients listed above, with zero missing ingredients. If it's truly impossible, minimize missing ingredients to 1 at most.
- The second and third recipes can use additional ingredients if needed.
- Strongly prefer priority 1 ingredients
- Then prefer priority 2 ingredients
- Use priority 3 ingredients when useful
- Minimize extra ingredients
- Keep recipes realistic and simple
- Make the dishes consistent with ${culture} cuisine
- "missing_ingredients" must ONLY contain ingredients the recipe needs that are NOT in the available ingredients list above. Do NOT list unused available ingredients here.

Return ONLY valid JSON in this exact format:
{
  "recipes": [
    {
      "title": "Recipe name",
      "description": "Short description",
      "culture": "${culture}",
      "ingredients_used": ["item1", "item2"],
      "priority_ingredients_used": ["item1"],
      "missing_ingredients": ["extra ingredient not in the fridge"],
      "steps": ["step 1", "step 2", "step 3"]
    }
  ]
}
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
          model: "meta-llama/Llama-3.1-8B-Instruct",
          messages: [
            { role: 'system', content: systemPrompt },
            { role: 'user', content: userPrompt }
          ],
          temperature: 0.7,
          max_tokens: 700
        }),
      }
    );

    const rawText = await hfResponse.text();

    if (!hfResponse.ok) {
      log(`HF error status: ${hfResponse.status}`);
      log(rawText);
      return res.json(
        {
          ok: false,
          error: 'Hugging Face request failed',
          status: hfResponse.status,
          details: rawText,
        },
        500
      );
    }

    let parsed;
    try {
      parsed = JSON.parse(rawText);
    } catch (e) {
      return res.json(
        {
          ok: false,
          error: 'Invalid JSON from Hugging Face',
          details: rawText,
        },
        500
      );
    }

    const generatedText = parsed?.choices?.[0]?.message?.content ?? '';

    if (!generatedText) {
      return res.json(
        {
          ok: false,
          error: 'Unexpected Hugging Face response shape',
          details: parsed,
        },
        500
      );
    }

    let recipesJson;
    try {
      recipesJson = JSON.parse(generatedText);
    } catch (e) {
      return res.json(
        {
          ok: true,
          warning: 'Model returned text instead of clean JSON',
          raw: generatedText,
        },
        200
      );
    }

    log(JSON.stringify(recipesJson, null, 2));
    return res.json({ ok: true, data: recipesJson }, 200);

  } catch (err) {
    error(err?.message || String(err));
    return res.json(
      {
        ok: false,
        error: err?.message || 'Unknown server error',
      },
      500
    );
  }
};