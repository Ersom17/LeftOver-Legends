// lib/widgets/mascot_tour/mascot_tour_i18n.dart
//
// Translation strings for the mascot walkthrough. The active language is
// driven by the app-wide `localeProvider` (EN / IT). Narrower than the old
// six-language set — matches the rest of the app's scope.

import '../../providers/locale_provider.dart';

class MascotStrings {
  final String welcomeTitle;
  final String welcomeBody;
  final String filterTitle;
  final String filterBody;
  final String addWalkIntroTitle;
  final String addWalkIntroBody;
  final String addWalkFabTitle;
  final String addWalkFabBody;
  final String addWalkManualTitle;
  final String addWalkManualBody;
  final String addWalkSaveTitle;
  final String addWalkSaveBody;
  final String addWalkDoneTitle;
  final String addWalkDoneBody;
  final String recipeWalkIntroTitle;
  final String recipeWalkIntroBody;
  final String recipeWalkOptionsTitle;
  final String recipeWalkOptionsBody;
  final String recipeWalkPickTitle;
  final String recipeWalkPickBody;
  final String recipeWalkYoutubeTitle;
  final String recipeWalkYoutubeBody;
  final String recipesTitle;
  final String recipesBody;
  final String learnTitle;
  final String learnBody;
  final String rewardsTitle;
  final String rewardsBody;
  final String profileTitle;
  final String profileBody;
  final String endTitle;
  final String endBody;
  final String next;
  final String back;
  final String skip;
  final String finish;
  final String tapToContinue;
  final String replayTooltip;

  const MascotStrings({
    required this.welcomeTitle,
    required this.welcomeBody,
    required this.filterTitle,
    required this.filterBody,
    required this.addWalkIntroTitle,
    required this.addWalkIntroBody,
    required this.addWalkFabTitle,
    required this.addWalkFabBody,
    required this.addWalkManualTitle,
    required this.addWalkManualBody,
    required this.addWalkSaveTitle,
    required this.addWalkSaveBody,
    required this.addWalkDoneTitle,
    required this.addWalkDoneBody,
    required this.recipeWalkIntroTitle,
    required this.recipeWalkIntroBody,
    required this.recipeWalkOptionsTitle,
    required this.recipeWalkOptionsBody,
    required this.recipeWalkPickTitle,
    required this.recipeWalkPickBody,
    required this.recipeWalkYoutubeTitle,
    required this.recipeWalkYoutubeBody,
    required this.recipesTitle,
    required this.recipesBody,
    required this.learnTitle,
    required this.learnBody,
    required this.rewardsTitle,
    required this.rewardsBody,
    required this.profileTitle,
    required this.profileBody,
    required this.endTitle,
    required this.endBody,
    required this.next,
    required this.back,
    required this.skip,
    required this.finish,
    required this.tapToContinue,
    required this.replayTooltip,
  });

  static MascotStrings forLanguage(AppLanguage lang) =>
      lang == AppLanguage.it ? _it : _en;

  static const _en = MascotStrings(
    welcomeTitle: 'Hey there, legend!',
    welcomeBody:
        "I'm Sprout. Stick with me — I'll show you how to turn leftovers into wins.",
    filterTitle: 'Spot what\'s expiring',
    filterBody:
        'Flip between All, Expiring and Fresh to catch food before it turns.',
    addWalkIntroTitle: 'Let\'s stock your pantry',
    addWalkIntroBody:
        'I\'ll walk you through adding your first item. I prefilled one so you just confirm.',
    addWalkFabTitle: 'Step 1 — open the adder',
    addWalkFabBody: 'Tap the highlighted "Add item" button to get started.',
    addWalkManualTitle: 'Step 2 — add manually',
    addWalkManualBody:
        'Pick "Add manually" so I can prefill the fields for you.',
    addWalkSaveTitle: 'Step 3 — just hit save',
    addWalkSaveBody:
        'All the fields are filled in already. Tap "Add to pantry" to confirm.',
    addWalkDoneTitle: 'Nice — your first item is in!',
    addWalkDoneBody:
        'That\'s it. From now on, adding takes ten seconds — or one receipt scan.',
    recipeWalkIntroTitle: 'Now turn pantry into dinner',
    recipeWalkIntroBody:
        'Tap "Generate recipes" and I\'ll cook up ideas with you.',
    recipeWalkOptionsTitle: 'Pick a cuisine',
    recipeWalkOptionsBody:
        'Default works great. Tap "Generate recipes" to confirm and let me work.',
    recipeWalkPickTitle: 'Take your pick',
    recipeWalkPickBody:
        'These are your ideas. Tap the highlighted one to see the full recipe.',
    recipeWalkYoutubeTitle: 'Need a video?',
    recipeWalkYoutubeBody:
        'Tap "Watch on YouTube" for a quick demo, or "Find recipe online" for a full writeup.',
    recipesTitle: 'Your recipe stash',
    recipesBody:
        'Bookmarked dishes live here — one tap to cook them again.',
    learnTitle: 'Learn the tricks',
    learnBody: 'Quick tips for storing food so it lasts longer. You got this.',
    rewardsTitle: 'Earn Seeds',
    rewardsBody: 'Eat what you buy, collect Seeds, trade them for real coupons.',
    profileTitle: 'Your HQ',
    profileBody: 'Settings, stats, and your total saved — all in one place.',
    endTitle: 'You\'re saving the world!',
    endBody:
        'Every item you eat is waste you didn\'t create. Thanks for being a legend. Now go cook something!',
    next: 'Next →',
    back: '← Back',
    skip: 'Skip tour',
    finish: 'Let\'s go!',
    tapToContinue: 'Tap the highlighted spot to continue',
    replayTooltip: 'Replay tour',
  );

  static const _it = MascotStrings(
    welcomeTitle: 'Ehi, leggenda!',
    welcomeBody:
        'Sono Germoglio. Seguimi — ti mostro come trasformare gli avanzi in vittorie.',
    filterTitle: 'Vedi cosa sta scadendo',
    filterBody:
        'Passa tra Tutti, In scadenza e Freschi per non perdere nulla.',
    addWalkIntroTitle: 'Riempiamo la dispensa',
    addWalkIntroBody:
        'Ti accompagno ad aggiungere il primo prodotto. L\'ho già compilato, tu confermi.',
    addWalkFabTitle: 'Passo 1 — apri l\'aggiunta',
    addWalkFabBody: 'Tocca il pulsante "Aggiungi" evidenziato per iniziare.',
    addWalkManualTitle: 'Passo 2 — aggiunta manuale',
    addWalkManualBody:
        'Scegli "Aggiungi manualmente" e ti compilo io i campi.',
    addWalkSaveTitle: 'Passo 3 — conferma',
    addWalkSaveBody:
        'I campi sono già pronti. Tocca "Aggiungi alla dispensa" per salvare.',
    addWalkDoneTitle: 'Perfetto — primo prodotto salvato!',
    addWalkDoneBody:
        'Fatto. Da adesso aggiungere richiede dieci secondi — o uno scontrino.',
    recipeWalkIntroTitle: 'Trasforma la dispensa in cena',
    recipeWalkIntroBody: 'Tocca "Genera ricette" e ti propongo idee.',
    recipeWalkOptionsTitle: 'Scegli la cucina',
    recipeWalkOptionsBody:
        'Il default va bene. Tocca "Genera ricette" per confermare.',
    recipeWalkPickTitle: 'Scegli una',
    recipeWalkPickBody:
        'Ecco le idee. Tocca quella evidenziata per vedere la ricetta completa.',
    recipeWalkYoutubeTitle: 'Serve un video?',
    recipeWalkYoutubeBody:
        'Tocca "Guarda su YouTube" per una demo, o "Trova la ricetta online" per il testo.',
    recipesTitle: 'Le tue ricette',
    recipesBody: 'I piatti preferiti stanno qui — un tocco e via.',
    learnTitle: 'Impara i trucchi',
    learnBody: 'Consigli rapidi per far durare il cibo più a lungo.',
    rewardsTitle: 'Raccogli Semi',
    rewardsBody:
        'Mangia quello che compri, raccogli Semi, trasformali in coupon.',
    profileTitle: 'Il tuo quartier generale',
    profileBody:
        'Impostazioni, statistiche e risparmi — tutto in un posto.',
    endTitle: 'Stai salvando il mondo!',
    endBody:
        'Ogni cosa che mangi è spreco evitato. Grazie, leggenda. E ora: ai fornelli!',
    next: 'Avanti →',
    back: '← Indietro',
    skip: 'Salta',
    finish: 'Andiamo!',
    tapToContinue: 'Tocca la zona evidenziata',
    replayTooltip: 'Rigioca il tour',
  );
}
