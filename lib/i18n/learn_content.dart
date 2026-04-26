// lib/i18n/learn_content.dart
//
// Data for the Learn section. Each topic has a localised title, blurb (for
// the list card) and a structured list of blocks rendered by
// LearnDetailScreen. Two languages only — EN and IT — to match AppStrings.
//
// Content is adapted (not verbatim) from the ENGR 422 Food Safety and the
// V2 Swiss-vs-US food education documents supplied by the product team.
//
// Region-aware: most topics are universal, but the "local habits" topic and
// the unit-system framing change between US and Europe. The earlier version
// of this file shipped a single side-by-side comparison; users found it
// confusing, so we now show only the side that matches the user's region.

import '../providers/locale_provider.dart';
import '../providers/region_provider.dart';

/// One renderable chunk inside a topic's detail screen.
sealed class LearnBlock {
  const LearnBlock();
}

class LearnParagraph extends LearnBlock {
  final String text;
  const LearnParagraph(this.text);
}

class LearnHeading extends LearnBlock {
  final String text;
  const LearnHeading(this.text);
}

class LearnBullets extends LearnBlock {
  final List<String> items;
  const LearnBullets(this.items);
}

class LearnCallout extends LearnBlock {
  final String emoji;
  final String text;
  const LearnCallout({required this.emoji, required this.text});
}

/// Side-by-side table, rendered as a two-column Table. Header cells are
/// optional — when null the table renders data rows only.
class LearnTable extends LearnBlock {
  final String? leftHeader;
  final String? rightHeader;
  final List<(String, String)> rows;
  const LearnTable({this.leftHeader, this.rightHeader, required this.rows});
}

class LearnTopic {
  final String id;
  final String emoji;
  final String title;
  final String blurb;
  final List<LearnBlock> blocks;

  const LearnTopic({
    required this.id,
    required this.emoji,
    required this.title,
    required this.blurb,
    required this.blocks,
  });
}

class LearnContent {
  /// Returns the topic list for the given language and region. Topics tagged
  /// with an `_onlyRegion` field are filtered out for the other region; the
  /// rest pass through untouched.
  static List<LearnTopic> forLanguageAndRegion(
    AppLanguage lang,
    AppRegion region,
  ) {
    final all = lang == AppLanguage.it ? _it : _en;
    return all.where((t) {
      // Topics whose id is `local-habits-us` only show in the US; same for
      // `local-habits-eu` in Europe. Everything else is universal.
      if (t.id == 'local-habits-us') return region == AppRegion.us;
      if (t.id == 'local-habits-eu') return region == AppRegion.europe;
      return true;
    }).toList();
  }

  /// Backwards-compatible accessor — defaults to the European catalog when
  /// no region is supplied. Prefer [forLanguageAndRegion] for new call sites.
  static List<LearnTopic> forLanguage(AppLanguage lang) =>
      forLanguageAndRegion(lang, AppRegion.europe);

  // ─── English ────────────────────────────────────────────────────────────
  static const _en = <LearnTopic>[
    LearnTopic(
      id: 'date-labels',
      emoji: '🏷️',
      title: 'Reading food date labels',
      blurb: 'What "Best By", "Use By", and "Sell By" actually mean.',
      blocks: [
        LearnParagraph(
          'Food date labels can be confusing. For most products, the date is about quality, not safety — and throwing food away on the printed date is one of the biggest drivers of household waste.',
        ),
        LearnHeading('Common terms, demystified'),
        LearnBullets([
          'Best By / Best Before — peak flavor and quality. Usually safe to eat past the date if stored properly.',
          'Use By — last date for peak quality on perishables. A few items (like infant formula) should not be eaten past this date.',
          'Sell By — a hint for the store\'s inventory. Food is typically safe days or weeks after.',
          'Expiration Date — rare; usually reserved for items where safety really does expire (infant formula, some medications).',
        ]),
        LearnCallout(
          emoji: '✅',
          text: 'Trust your senses more than the printed date for most foods — look, smell, feel.',
        ),
      ],
    ),
    LearnTopic(
      id: 'spoilage-signs',
      emoji: '👃',
      title: 'Is it still good?',
      blurb: 'Sight, smell and texture checks for produce, dairy, meat and eggs.',
      blocks: [
        LearnHeading('Fruits and vegetables'),
        LearnBullets([
          'Mold with fuzzy green, white, or black spots.',
          'Slimy or mushy texture.',
          'Strong or fermented smell.',
          'Excessive leaking or heavy browning.',
        ]),
        LearnParagraph(
          'Slightly soft or wrinkled produce is usually still usable — think soups, sauces, baking.',
        ),
        LearnHeading('Dairy'),
        LearnBullets([
          'Sour smell.',
          'Curdling or separation in milk.',
          'Mold growth on soft cheeses — discard.',
          'Unusual flavor.',
        ]),
        LearnCallout(
          emoji: '🧀',
          text: 'Hard cheeses (parmesan, pecorino) are resilient: trim a small mold spot and the rest is typically fine.',
        ),
        LearnHeading('Meat, poultry and seafood'),
        LearnBullets([
          'Sticky or slimy surface.',
          'Rotten or sulfur-like odor.',
          'Gray, green or dull coloring.',
        ]),
        LearnCallout(
          emoji: '⚠️',
          text: 'Do not taste meat or seafood to test freshness — when in doubt, throw it out.',
        ),
        LearnHeading('Eggs'),
        LearnBullets([
          'Strong or foul smell once cracked.',
          'Float test: an egg that floats in water may be old — inspect carefully before using.',
        ]),
      ],
    ),
    LearnTopic(
      id: 'leaving-out',
      emoji: '⏱️',
      title: 'How long food can sit out',
      blurb: 'Room-temperature safety windows for cooked and perishable food.',
      blocks: [
        LearnParagraph(
          'Bacteria grow quickly at room temperature, especially on cooked and perishable foods. These limits exist to keep you out of the "danger zone" between 40°F (4°C) and 140°F (60°C).',
        ),
        LearnHeading('Safe time limits'),
        LearnBullets([
          '2 hours maximum at normal room temperature.',
          '1 hour if the room is above 90°F (32°C).',
          'Refrigerate leftovers promptly in shallow containers.',
        ]),
        LearnCallout(
          emoji: '❌',
          text: 'Never leave cooked dishes out overnight — the reheat the next day will not undo the bacterial growth.',
        ),
      ],
    ),
    LearnTopic(
      id: 'fridge-pantry',
      emoji: '🧊',
      title: 'Fridge & pantry storage',
      blurb: 'Temperatures, shelf order, and keeping dry goods dry.',
      blocks: [
        LearnHeading('Refrigerator best practices'),
        LearnBullets([
          'Keep the fridge at or below 40°F (4°C).',
          'Store raw meat on the bottom shelf so drips can\'t reach other food.',
          'Use airtight containers for leftovers.',
          'Label leftovers with the preparation date.',
        ]),
        LearnHeading('Pantry tips'),
        LearnBullets([
          'Store dry and canned goods in a cool, dry spot.',
          'Keep opened dry goods in sealed containers — moisture is the enemy.',
          'Use First In, First Out: place new stock behind older stock.',
        ]),
      ],
    ),
    LearnTopic(
      id: 'freezing',
      emoji: '❄️',
      title: 'Freezing food safely',
      blurb: 'What to freeze, how to package, how long it keeps.',
      blocks: [
        LearnParagraph(
          'Freezing slows spoilage dramatically and can rescue food you know you won\'t finish in time. The only real limit is quality degradation — freezer burn and texture loss.',
        ),
        LearnHeading('Best practices'),
        LearnBullets([
          'Freeze food before it spoils, not after.',
          'Use freezer-safe airtight packaging.',
          'Remove as much air as possible (press flat, vacuum seal if you have one).',
          'Label every package with the freeze date.',
        ]),
        LearnHeading('Typical freezer storage times'),
        LearnBullets([
          'Meat: 6–12 months.',
          'Cooked meals: 2–3 months.',
          'Fruits and vegetables: 8–12 months.',
          'Bread: 2–3 months.',
        ]),
        LearnCallout(
          emoji: '✅',
          text: 'Frozen food stays technically safe indefinitely — but quality degrades, so rotate the freezer too.',
        ),
      ],
    ),
    LearnTopic(
      id: 'reducing-waste',
      emoji: '♻️',
      title: 'Reducing food waste & SDG 12.3',
      blurb: 'Why it matters, and what UN Goal 12.3 asks of households.',
      blocks: [
        LearnHeading('The numbers'),
        LearnBullets([
          'About one third of all food produced globally is wasted.',
          'Food waste is a major contributor to greenhouse-gas emissions.',
          'Households are among the largest single sources of food waste.',
        ]),
        LearnHeading('SDG 12.3'),
        LearnParagraph(
          'UN Sustainable Development Goal 12.3 aims to halve global food waste per capita by 2030 — a target that the household tier needs to hit to succeed.',
        ),
        LearnHeading('What you can do'),
        LearnBullets([
          'Learn how to read food labels so you don\'t discard good food.',
          'Store food properly (see the fridge & pantry topic).',
          'Freeze food before it spoils.',
          'Use leftovers creatively — soups, stir-fries, frittatas.',
          'Buy only what you need and shop more frequently if you can.',
        ]),
        LearnCallout(
          emoji: '🌍',
          text: 'Small household changes compound into meaningful system-level impact.',
        ),
      ],
    ),
    LearnTopic(
      id: 'local-habits-us',
      emoji: '🇺🇸',
      title: 'Food habits in the US',
      blurb: 'How storage, labels, and shopping work in the US.',
      blocks: [
        LearnParagraph(
          'These are the default conventions you\'ll see in US grocery stores and home kitchens. Knowing them helps you read labels and store things correctly.',
        ),
        LearnHeading('Storage defaults'),
        LearnBullets([
          'Eggs: washed at the supplier — must be refrigerated.',
          'Milk: pasteurized, refrigerated, 7–14 days after opening.',
          'Bread: often refrigerated, plastic-wrapped.',
          'Hard cheese: any mold treated as spoilage.',
          'Potatoes and tomatoes: often refrigerated by default.',
          'Shopping cadence: large, infrequent trips.',
        ]),
        LearnHeading('Date labels'),
        LearnBullets([
          '"Best By" = quality, not safety. Almost always still safe past it.',
          '"Use By" usually means quality too — the only true exception is infant formula.',
          'Dates drive a lot of household discards. Trust your senses first.',
        ]),
        LearnHeading('Cultural defaults'),
        LearnBullets([
          '"When in doubt, throw it out" is the common reflex.',
          'Low tolerance for any mold.',
          'The fridge tends to be the default answer for storage.',
          'Plastic, airtight packaging is the norm.',
        ]),
        LearnCallout(
          emoji: '✅',
          text: 'Pause before tossing on the printed date — for most items it\'s a quality marker, not a safety one.',
        ),
      ],
    ),
    LearnTopic(
      id: 'local-habits-eu',
      emoji: '🇨🇭',
      title: 'Food habits in Switzerland',
      blurb: 'How storage, labels, and shopping work in Switzerland.',
      blocks: [
        LearnParagraph(
          'These are the default conventions you\'ll see in Swiss grocery stores and home kitchens. They lean toward smaller, more frequent shops and selective refrigeration.',
        ),
        LearnHeading('Storage defaults'),
        LearnBullets([
          'Eggs: unwashed; keep at room temperature for up to ~21 days.',
          'UHT milk is common — shelf-stable until opened.',
          'Bread: never refrigerated; store in paper or cloth.',
          'Hard cheese: trim small mold off, keep breathable.',
          'Potatoes: cool, dark, ventilated. Tomatoes: room temperature.',
          'Shopping cadence: smaller, more frequent trips.',
        ]),
        LearnHeading('Date labels'),
        LearnBullets([
          '"Mindestens haltbar bis" / "À consommer de préférence avant" = quality indicator. Likely fine after the date.',
          '"Zu verbrauchen bis" / "À consommer jusqu\'au" is a strict safety date — illegal for shops to sell past it.',
          'Sensory checks are encouraged — look, smell, taste-of-doubt.',
        ]),
        LearnHeading('Cultural defaults'),
        LearnBullets([
          '"Assess the condition before discarding" is the common reflex.',
          'Mold tolerance depends on the product (cured meats, hard cheese).',
          'Selective refrigeration — not everything goes in the fridge.',
          'Paper, breathable, minimal packaging is the norm.',
        ]),
        LearnCallout(
          emoji: '✅',
          text: 'Use your senses first; the printed date is a guideline, not a hard cutoff (except "Zu verbrauchen bis" / "À consommer jusqu\'au").',
        ),
      ],
    ),
    LearnTopic(
      id: 'conversions',
      emoji: '⚖️',
      title: 'Kitchen conversions',
      blurb: 'Volume, weight, temperature and calorie quick reference.',
      blocks: [
        LearnHeading('Volume'),
        LearnTable(
          leftHeader: 'Metric',
          rightHeader: 'U.S. customary',
          rows: [
            ('5 mL', '1 teaspoon'),
            ('15 mL', '1 tablespoon'),
            ('60 mL', '¼ cup'),
            ('80 mL', '⅓ cup'),
            ('120 mL', '½ cup'),
            ('180 mL', '¾ cup'),
            ('240 mL', '1 cup'),
            ('500 mL', '~1 pint'),
            ('1 L', '~1.05 quart'),
            ('3.8 L', '1 gallon'),
          ],
        ),
        LearnHeading('Weight'),
        LearnTable(
          leftHeader: 'Metric',
          rightHeader: 'U.S.',
          rows: [
            ('28 g', '1 oz'),
            ('100 g', '3.5 oz'),
            ('227 g', '8 oz (½ lb)'),
            ('454 g', '1 lb'),
            ('1 kg', '2.2 lb'),
          ],
        ),
        LearnHeading('Temperature'),
        LearnTable(
          leftHeader: 'Celsius',
          rightHeader: 'Fahrenheit',
          rows: [
            ('150°C', '300°F'),
            ('165°C', '325°F'),
            ('175°C', '350°F'),
            ('190°C', '375°F'),
            ('205°C', '400°F'),
            ('220°C', '425°F'),
          ],
        ),
        LearnHeading('Calories'),
        LearnParagraph(
          'US packaging lists Calories per serving. Swiss / EU packaging lists energy (kcal and kJ) per 100 g or 100 ml, so you can compare energy density across products.',
        ),
        LearnCallout(emoji: 'ℹ️', text: '1 kcal = 1 Cal = 4.184 kJ'),
      ],
    ),
  ];

  // ─── Italiano ───────────────────────────────────────────────────────────
  static const _it = <LearnTopic>[
    LearnTopic(
      id: 'date-labels',
      emoji: '🏷️',
      title: 'Leggere le etichette',
      blurb: 'Cosa significano davvero "Da consumarsi entro" e "Preferibilmente entro".',
      blocks: [
        LearnParagraph(
          'Le etichette con le date confondono. Per la maggior parte dei prodotti indicano la qualità, non la sicurezza — buttare cibo alla data stampata è una delle cause principali dello spreco domestico.',
        ),
        LearnHeading('Termini spiegati'),
        LearnBullets([
          'Preferibilmente entro (Best Before) — qualità e gusto migliori. Spesso è sicuro anche dopo, se conservato bene.',
          'Da consumarsi entro (Use By) — ultima data di qualità ottimale sui deperibili. Alcuni prodotti (come il latte artificiale) non vanno consumati oltre.',
          'Vendibile fino a (Sell By) — riferimento del negozio. L\'alimento è in genere sicuro per giorni o settimane.',
          'Data di scadenza — rara, di solito riservata a prodotti dove la sicurezza scade davvero.',
        ]),
        LearnCallout(
          emoji: '✅',
          text: 'Per la maggior parte degli alimenti, fidati dei tuoi sensi più della data: guarda, annusa, tocca.',
        ),
      ],
    ),
    LearnTopic(
      id: 'spoilage-signs',
      emoji: '👃',
      title: 'È ancora buono?',
      blurb: 'Controlli visivi, olfattivi e tattili per frutta, latticini, carne e uova.',
      blocks: [
        LearnHeading('Frutta e verdura'),
        LearnBullets([
          'Muffa con macchie verdi, bianche o nere.',
          'Consistenza viscida o molliccia.',
          'Odore forte o fermentato.',
          'Perdite di liquido o macchie marroni estese.',
        ]),
        LearnParagraph(
          'Un po\' molla o grinzosa è spesso ancora utilizzabile: zuppe, sughi, dolci.',
        ),
        LearnHeading('Latticini'),
        LearnBullets([
          'Odore acidulo.',
          'Latte cagliato o separato.',
          'Muffa sui formaggi freschi — scarta.',
          'Sapore inconsueto.',
        ]),
        LearnCallout(
          emoji: '🧀',
          text: 'I formaggi stagionati (parmigiano, pecorino) sono resistenti: taglia via la macchia di muffa e il resto in genere va bene.',
        ),
        LearnHeading('Carne, pollame e pesce'),
        LearnBullets([
          'Superficie appiccicosa o viscida.',
          'Odore marcio o simile a zolfo.',
          'Colore grigio, verde o spento.',
        ]),
        LearnCallout(
          emoji: '⚠️',
          text: 'Non assaggiare carne o pesce per verificarne la freschezza — nel dubbio, buttali.',
        ),
        LearnHeading('Uova'),
        LearnBullets([
          'Odore forte o sgradevole una volta rotte.',
          'Prova del galleggiamento: un uovo che galleggia potrebbe essere vecchio — controlla con attenzione.',
        ]),
      ],
    ),
    LearnTopic(
      id: 'leaving-out',
      emoji: '⏱️',
      title: 'Quanto può stare fuori',
      blurb: 'Tempi di sicurezza a temperatura ambiente per piatti cotti e deperibili.',
      blocks: [
        LearnParagraph(
          'I batteri si moltiplicano rapidamente a temperatura ambiente, soprattutto su cibi cotti e deperibili. Questi limiti servono a evitare la "zona pericolosa" tra 4°C e 60°C.',
        ),
        LearnHeading('Limiti di tempo'),
        LearnBullets([
          '2 ore massimo a temperatura ambiente normale.',
          '1 ora se la stanza supera i 32°C.',
          'Metti gli avanzi in frigo subito, in contenitori bassi.',
        ]),
        LearnCallout(
          emoji: '❌',
          text: 'Non lasciare i cibi cotti fuori tutta la notte — riscaldarli il giorno dopo non elimina i batteri.',
        ),
      ],
    ),
    LearnTopic(
      id: 'fridge-pantry',
      emoji: '🧊',
      title: 'Frigo e dispensa',
      blurb: 'Temperature, ordine dei ripiani e come tenere asciutti i prodotti secchi.',
      blocks: [
        LearnHeading('Frigorifero'),
        LearnBullets([
          'Tieni il frigo a 4°C o meno.',
          'Metti la carne cruda sul ripiano più basso: i liquidi non raggiungono gli altri alimenti.',
          'Conserva gli avanzi in contenitori ermetici.',
          'Etichetta gli avanzi con la data di preparazione.',
        ]),
        LearnHeading('Dispensa'),
        LearnBullets([
          'Tieni i prodotti secchi e in scatola in un posto fresco e asciutto.',
          'Chiudi i prodotti secchi aperti in contenitori sigillati — l\'umidità è il nemico.',
          'Rotazione FIFO (First In, First Out): metti i nuovi dietro ai vecchi.',
        ]),
      ],
    ),
    LearnTopic(
      id: 'freezing',
      emoji: '❄️',
      title: 'Congelare in sicurezza',
      blurb: 'Cosa congelare, come confezionare, quanto tempo si conserva.',
      blocks: [
        LearnParagraph(
          'Congelare rallenta molto il deterioramento e può salvare cibi che sai che non finirai in tempo. L\'unico vero limite è la qualità: bruciature da freezer e perdita di consistenza.',
        ),
        LearnHeading('Buone pratiche'),
        LearnBullets([
          'Congela prima che vada a male, non dopo.',
          'Usa confezioni ermetiche adatte al freezer.',
          'Elimina quanta più aria possibile (schiaccia o usa il sottovuoto).',
          'Etichetta ogni pacchetto con la data di congelamento.',
        ]),
        LearnHeading('Tempi tipici di conservazione'),
        LearnBullets([
          'Carne: 6–12 mesi.',
          'Piatti cotti: 2–3 mesi.',
          'Frutta e verdura: 8–12 mesi.',
          'Pane: 2–3 mesi.',
        ]),
        LearnCallout(
          emoji: '✅',
          text: 'Il cibo congelato è tecnicamente sicuro a tempo indeterminato, ma la qualità cala: ruota anche il freezer.',
        ),
      ],
    ),
    LearnTopic(
      id: 'reducing-waste',
      emoji: '♻️',
      title: 'Ridurre gli sprechi + SDG 12.3',
      blurb: 'Perché conta, e cosa chiede l\'Obiettivo ONU 12.3.',
      blocks: [
        LearnHeading('I numeri'),
        LearnBullets([
          'Circa un terzo del cibo prodotto nel mondo viene sprecato.',
          'Lo spreco alimentare è un importante fattore di emissioni di gas serra.',
          'Le famiglie sono tra le fonti maggiori di spreco alimentare.',
        ]),
        LearnHeading('SDG 12.3'),
        LearnParagraph(
          'L\'Obiettivo 12.3 dell\'Agenda ONU punta a dimezzare lo spreco alimentare pro capite entro il 2030 — un traguardo raggiungibile solo con il contributo delle famiglie.',
        ),
        LearnHeading('Cosa puoi fare'),
        LearnBullets([
          'Impara a leggere le etichette per non scartare cibo buono.',
          'Conserva bene (vedi il capitolo frigo & dispensa).',
          'Congela prima che vada a male.',
          'Usa gli avanzi in modo creativo: zuppe, saltati in padella, frittate.',
          'Compra solo quello che ti serve, possibilmente più spesso.',
        ]),
        LearnCallout(
          emoji: '🌍',
          text: 'I piccoli cambiamenti domestici si sommano in un impatto significativo a livello di sistema.',
        ),
      ],
    ),
    LearnTopic(
      id: 'local-habits-us',
      emoji: '🇺🇸',
      title: 'Abitudini alimentari negli USA',
      blurb: 'Come funzionano conservazione, etichette e spesa negli Stati Uniti.',
      blocks: [
        LearnParagraph(
          'Sono le convenzioni che trovi nei supermercati americani e nelle cucine di casa. Conoscerle ti aiuta a leggere le etichette e a conservare bene gli alimenti.',
        ),
        LearnHeading('Conservazione'),
        LearnBullets([
          'Uova: lavate dal fornitore — sempre in frigo.',
          'Latte: pastorizzato, in frigo, 7–14 giorni dopo l\'apertura.',
          'Pane: spesso in frigo, in plastica.',
          'Formaggio stagionato: la muffa viene considerata deterioramento.',
          'Patate e pomodori: spesso in frigo per default.',
          'Spesa: grandi acquisti poco frequenti.',
        ]),
        LearnHeading('Etichette'),
        LearnBullets([
          '"Best By" = qualità, non sicurezza. Quasi sempre sicuro anche dopo.',
          '"Use By" di solito è qualità — l\'unica vera eccezione è il latte artificiale.',
          'Le date guidano molti scarti domestici. Fidati prima dei sensi.',
        ]),
        LearnHeading('Norme culturali'),
        LearnBullets([
          '"Nel dubbio, butta" è il riflesso comune.',
          'Bassa tolleranza per qualsiasi muffa.',
          'Il frigo come risposta di default.',
          'Imballaggi ermetici in plastica.',
        ]),
        LearnCallout(
          emoji: '✅',
          text: 'Fermati prima di buttare alla data stampata: per la maggior parte dei prodotti è una scadenza di qualità, non di sicurezza.',
        ),
      ],
    ),
    LearnTopic(
      id: 'local-habits-eu',
      emoji: '🇨🇭',
      title: 'Abitudini alimentari in Svizzera',
      blurb: 'Come funzionano conservazione, etichette e spesa in Svizzera.',
      blocks: [
        LearnParagraph(
          'Sono le convenzioni che trovi nei supermercati svizzeri e nelle cucine di casa. La cultura privilegia spese più piccole e frequenti, e una refrigerazione selettiva.',
        ),
        LearnHeading('Conservazione'),
        LearnBullets([
          'Uova: non lavate, a temperatura ambiente fino a ~21 giorni.',
          'Latte UHT diffuso — a scaffale fino all\'apertura.',
          'Pane: mai in frigo, in carta o in tela.',
          'Formaggio stagionato: rimuovi la piccola muffa, tienilo traspirante.',
          'Patate: fresco, buio, ventilato. Pomodori: temperatura ambiente.',
          'Spesa: più piccola e più frequente.',
        ]),
        LearnHeading('Etichette'),
        LearnBullets([
          '"Preferibilmente entro" = indicatore di qualità. Spesso buono anche dopo.',
          '"Da consumarsi entro" è una data di sicurezza rigorosa: illegale vendere dopo.',
          'Si raccomanda il controllo sensoriale: vista, olfatto, tatto.',
        ]),
        LearnHeading('Norme culturali'),
        LearnBullets([
          '"Valuta prima di scartare" è il riflesso comune.',
          'La tolleranza alla muffa dipende dal prodotto (salumi, formaggi stagionati).',
          'Refrigerazione selettiva: non tutto va in frigo.',
          'Imballaggi in carta, traspiranti, minimi.',
        ]),
        LearnCallout(
          emoji: '✅',
          text: 'Usa prima i sensi; la data stampata è una guida (eccetto "Da consumarsi entro").',
        ),
      ],
    ),
    LearnTopic(
      id: 'conversions',
      emoji: '⚖️',
      title: 'Conversioni di cucina',
      blurb: 'Volumi, pesi, temperature e calorie — la tabella rapida.',
      blocks: [
        LearnHeading('Volume'),
        LearnTable(
          leftHeader: 'Metrico',
          rightHeader: 'Unità USA',
          rows: [
            ('5 mL', '1 cucchiaino'),
            ('15 mL', '1 cucchiaio'),
            ('60 mL', '¼ cup'),
            ('80 mL', '⅓ cup'),
            ('120 mL', '½ cup'),
            ('180 mL', '¾ cup'),
            ('240 mL', '1 cup'),
            ('500 mL', '~1 pint'),
            ('1 L', '~1,05 quart'),
            ('3,8 L', '1 gallone'),
          ],
        ),
        LearnHeading('Peso'),
        LearnTable(
          leftHeader: 'Metrico',
          rightHeader: 'USA',
          rows: [
            ('28 g', '1 oz'),
            ('100 g', '3,5 oz'),
            ('227 g', '8 oz (½ lb)'),
            ('454 g', '1 lb'),
            ('1 kg', '2,2 lb'),
          ],
        ),
        LearnHeading('Temperatura'),
        LearnTable(
          leftHeader: 'Celsius',
          rightHeader: 'Fahrenheit',
          rows: [
            ('150°C', '300°F'),
            ('165°C', '325°F'),
            ('175°C', '350°F'),
            ('190°C', '375°F'),
            ('205°C', '400°F'),
            ('220°C', '425°F'),
          ],
        ),
        LearnHeading('Calorie'),
        LearnParagraph(
          'Le etichette USA indicano le Calorie per porzione. Quelle svizzere/europee indicano l\'energia (kcal e kJ) per 100 g o 100 ml, così puoi confrontare la densità energetica tra prodotti.',
        ),
        LearnCallout(emoji: 'ℹ️', text: '1 kcal = 1 Cal = 4,184 kJ'),
      ],
    ),
  ];
}
