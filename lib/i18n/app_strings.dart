// lib/i18n/app_strings.dart
//
// Flat container for every user-facing string in the app. Two concrete
// instances (_en, _it) are resolved via `AppStrings.of(AppLanguage)` and
// typically consumed through `appStringsProvider` in locale_provider.dart.
//
// Keep the field list alphabetically grouped by screen for easy scanning.

import '../providers/locale_provider.dart' show AppLanguage;

class AppStrings {
  // ─── Common actions ─────────────────────────────────────────────────────
  final String cancel;
  final String save;
  final String delete;
  final String edit;
  final String back;
  final String close;
  final String retry;
  final String loading;

  // ─── Fridge / Pantry screen ─────────────────────────────────────────────
  final String pantryTitle;
  final String filterAll;
  final String filterExpiring;
  final String filterFresh;
  final String noItemsHere;
  final String itemCountOne;
  final String itemCountMany;
  final String addItem;
  final String addManually;
  final String addManuallySubtitle;
  final String scanReceipt;
  final String scanReceiptSubtitle;
  final String generateRecipes;
  final String generating;
  final String noItemsDetected;
  final String receiptScanFailed;
  final String logout;

  // Bottom nav
  final String navHome;
  final String navRecipes;
  final String navLearn;
  final String navRewards;
  final String navProfile;

  // Scanning overlay
  final String scanCapturing;
  final String scanReadingNames;
  final String scanDetectingPrices;
  final String scanEstimatingExpiry;
  final String scanAlmostDone;
  final String scanning;
  final String scanImperfectNotice;

  // ─── Item form (Add & Edit) ─────────────────────────────────────────────
  final String addItemScreenTitle;
  final String editItemScreenTitle;
  final String itemNameLabel;
  final String itemNameHint;
  final String emojiLabelUpper;
  final String emojiOptionalLabel;
  final String emojiNone;
  final String categoryLabel;
  final String expiryDateLabel;
  final String priceAndCurrencyLabel;
  final String priceHint;
  final String defaultCurrencyPrefix;
  final String addToPantry;
  final String itemAddedSuccess;
  final String itemAddError;
  final String saveChanges;
  final String itemUpdatedSuccess;

  // Categories
  final String categoryDairy;
  final String categoryVeggies;
  final String categoryFruit;
  final String categoryProtein;
  final String categoryGrains;
  final String categoryOther;

  // ─── Profile ────────────────────────────────────────────────────────────
  final String profileTitle;
  final String profileYourStats;
  final String profilePoints;
  final String profileTotalSpent;
  final String profileTotalWasted;
  final String profileSettings;
  final String profileCountryLabel;
  final String profileLanguageLabel;
  final String profileReplayTour;
  final String profileCurrencyPrefix;

  // ─── Login ──────────────────────────────────────────────────────────────
  final String loginTitle;
  final String loginEmail;
  final String loginPassword;
  final String loginButton;
  final String loginRegisterButton;
  final String loginFailure;

  // ─── Recipes list ──────────────────────────────────────────────────────
  final String recipesTitle;
  final String recipesBestMatch;
  final String recipesStepsSuffix;
  final String recipesError;

  // ─── Recipe detail ─────────────────────────────────────────────────────
  final String detailWatchYoutube;
  final String detailFindOnline;
  final String detailFromFridge;
  final String detailAlsoNeed;
  final String detailSteps;
  final String detailSaveFavorite;
  final String detailRemoveFavorite;
  final String consumeIdleNone;
  final String consumeLoading;
  final String consumeCtaPrefix;
  final String consumeCtaItemOne;
  final String consumeCtaItemMany;
  final String consumeDialogTitle;
  final String consumeDialogBody;
  final String consumeDialogConfirm;
  final String consumeSuccessOne;
  final String consumeSuccessMany;
  final String consumeFailure;

  // ─── Recipe options sheet ──────────────────────────────────────────────
  final String optionsTitle;
  final String optionsSuggestedPrefix;
  final String optionsYourDefault;
  final String optionsPickCountry;
  final String optionsCuisinePrefix;
  final String optionsGenerate;

  // ─── Favorites ─────────────────────────────────────────────────────────
  final String favoritesTitle;
  final String favoritesEmpty;

  // ─── Rewards ───────────────────────────────────────────────────────────
  final String rewardsTitle;
  final String rewardsYourSeeds;
  final String rewardsAvailableCoupons;

  // ─── Learn ─────────────────────────────────────────────────────────────
  final String learnTitle;
  final String learnIntro;
  final String learnRegionPrefix;
  final String learnRegionUS;
  final String learnRegionEU;

  const AppStrings({
    required this.cancel,
    required this.save,
    required this.delete,
    required this.edit,
    required this.back,
    required this.close,
    required this.retry,
    required this.loading,
    required this.pantryTitle,
    required this.filterAll,
    required this.filterExpiring,
    required this.filterFresh,
    required this.noItemsHere,
    required this.itemCountOne,
    required this.itemCountMany,
    required this.addItem,
    required this.addManually,
    required this.addManuallySubtitle,
    required this.scanReceipt,
    required this.scanReceiptSubtitle,
    required this.generateRecipes,
    required this.generating,
    required this.noItemsDetected,
    required this.receiptScanFailed,
    required this.logout,
    required this.navHome,
    required this.navRecipes,
    required this.navLearn,
    required this.navRewards,
    required this.navProfile,
    required this.scanCapturing,
    required this.scanReadingNames,
    required this.scanDetectingPrices,
    required this.scanEstimatingExpiry,
    required this.scanAlmostDone,
    required this.scanning,
    required this.scanImperfectNotice,
    required this.addItemScreenTitle,
    required this.editItemScreenTitle,
    required this.itemNameLabel,
    required this.itemNameHint,
    required this.emojiLabelUpper,
    required this.emojiOptionalLabel,
    required this.emojiNone,
    required this.categoryLabel,
    required this.expiryDateLabel,
    required this.priceAndCurrencyLabel,
    required this.priceHint,
    required this.defaultCurrencyPrefix,
    required this.addToPantry,
    required this.itemAddedSuccess,
    required this.itemAddError,
    required this.saveChanges,
    required this.itemUpdatedSuccess,
    required this.categoryDairy,
    required this.categoryVeggies,
    required this.categoryFruit,
    required this.categoryProtein,
    required this.categoryGrains,
    required this.categoryOther,
    required this.profileTitle,
    required this.profileYourStats,
    required this.profilePoints,
    required this.profileTotalSpent,
    required this.profileTotalWasted,
    required this.profileSettings,
    required this.profileCountryLabel,
    required this.profileLanguageLabel,
    required this.profileReplayTour,
    required this.profileCurrencyPrefix,
    required this.loginTitle,
    required this.loginEmail,
    required this.loginPassword,
    required this.loginButton,
    required this.loginRegisterButton,
    required this.loginFailure,
    required this.recipesTitle,
    required this.recipesBestMatch,
    required this.recipesStepsSuffix,
    required this.recipesError,
    required this.detailWatchYoutube,
    required this.detailFindOnline,
    required this.detailFromFridge,
    required this.detailAlsoNeed,
    required this.detailSteps,
    required this.detailSaveFavorite,
    required this.detailRemoveFavorite,
    required this.consumeIdleNone,
    required this.consumeLoading,
    required this.consumeCtaPrefix,
    required this.consumeCtaItemOne,
    required this.consumeCtaItemMany,
    required this.consumeDialogTitle,
    required this.consumeDialogBody,
    required this.consumeDialogConfirm,
    required this.consumeSuccessOne,
    required this.consumeSuccessMany,
    required this.consumeFailure,
    required this.optionsTitle,
    required this.optionsSuggestedPrefix,
    required this.optionsYourDefault,
    required this.optionsPickCountry,
    required this.optionsCuisinePrefix,
    required this.optionsGenerate,
    required this.favoritesTitle,
    required this.favoritesEmpty,
    required this.rewardsTitle,
    required this.rewardsYourSeeds,
    required this.rewardsAvailableCoupons,
    required this.learnTitle,
    required this.learnIntro,
    required this.learnRegionPrefix,
    required this.learnRegionUS,
    required this.learnRegionEU,
  });

  static AppStrings of(AppLanguage lang) =>
      lang == AppLanguage.it ? _it : _en;

  // ─── English ────────────────────────────────────────────────────────────
  static const AppStrings _en = AppStrings(
    cancel: 'Cancel',
    save: 'Save',
    delete: 'Delete',
    edit: 'Edit',
    back: 'Back',
    close: 'Close',
    retry: 'Retry',
    loading: 'Loading…',
    pantryTitle: 'My Pantry',
    filterAll: 'All',
    filterExpiring: 'Expiring',
    filterFresh: 'Fresh',
    noItemsHere: 'No items here.',
    itemCountOne: 'item',
    itemCountMany: 'items',
    addItem: 'Add item',
    addManually: 'Add manually',
    addManuallySubtitle: 'Fill in item details yourself',
    scanReceipt: 'Scan receipt',
    scanReceiptSubtitle: 'Snap a photo of your grocery receipt',
    generateRecipes: 'Generate recipes',
    generating: 'Generating…',
    noItemsDetected:
        "No items detected. Some receipts don't scan perfectly — you can always add items manually.",
    receiptScanFailed: 'Receipt scan failed',
    logout: 'Log out',
    navHome: 'Home',
    navRecipes: 'Recipes',
    navLearn: 'Learn',
    navRewards: 'Rewards',
    navProfile: 'Profile',
    scanCapturing: 'Capturing receipt…',
    scanReadingNames: 'Reading item names…',
    scanDetectingPrices: 'Detecting prices…',
    scanEstimatingExpiry: 'Estimating expiry dates…',
    scanAlmostDone: 'Almost done…',
    scanning: 'Scanning…',
    scanImperfectNotice:
        'Some receipts may not scan perfectly — you can always add items manually.',
    addItemScreenTitle: 'Add item',
    editItemScreenTitle: 'Edit item',
    itemNameLabel: 'Item name',
    itemNameHint: 'e.g. Whole Milk',
    emojiLabelUpper: 'EMOJI (OPTIONAL)',
    emojiOptionalLabel: '(optional)',
    emojiNone: 'None selected',
    categoryLabel: 'Category',
    expiryDateLabel: 'Expiry date',
    priceAndCurrencyLabel: 'Price & Currency',
    priceHint: 'e.g. 2.95',
    defaultCurrencyPrefix: 'Default: ',
    addToPantry: 'Add to pantry',
    itemAddedSuccess: 'Item added successfully',
    itemAddError: 'Error adding item',
    saveChanges: 'Save changes',
    itemUpdatedSuccess: 'Item updated',
    categoryDairy: 'Dairy',
    categoryVeggies: 'Veggies',
    categoryFruit: 'Fruit',
    categoryProtein: 'Protein',
    categoryGrains: 'Grains',
    categoryOther: 'Other',
    profileTitle: 'Profile',
    profileYourStats: 'Your stats',
    profilePoints: 'Points',
    profileTotalSpent: 'Total spent',
    profileTotalWasted: 'Total wasted',
    profileSettings: 'Settings',
    profileCountryLabel: 'COUNTRY',
    profileLanguageLabel: 'LANGUAGE',
    profileReplayTour: 'Replay app tour',
    profileCurrencyPrefix: 'Currency: ',
    loginTitle: 'Log in',
    loginEmail: 'Email',
    loginPassword: 'Password',
    loginButton: 'Log in',
    loginRegisterButton: 'Create account',
    loginFailure: 'Could not sign in',
    recipesTitle: 'Generated recipes',
    recipesBestMatch: 'Best match',
    recipesStepsSuffix: 'steps',
    recipesError: 'Recipe error',
    detailWatchYoutube: 'Watch on YouTube',
    detailFindOnline: 'Find recipe online',
    detailFromFridge: 'From your fridge',
    detailAlsoNeed: "You'll also need",
    detailSteps: 'Steps',
    detailSaveFavorite: 'Save to favorites',
    detailRemoveFavorite: 'Remove from favorites',
    consumeIdleNone: 'No pantry items to consume',
    consumeLoading: 'Consuming…',
    consumeCtaPrefix: 'I cooked this · use ',
    consumeCtaItemOne: 'item',
    consumeCtaItemMany: 'items',
    consumeDialogTitle: 'Mark as cooked?',
    consumeDialogBody: 'These pantry items will be consumed:',
    consumeDialogConfirm: 'Consume',
    consumeSuccessOne: 'Consumed 1 item. Nice cooking!',
    consumeSuccessMany: 'Consumed {n} items. Nice cooking!',
    consumeFailure: 'Could not consume items',
    optionsTitle: 'Recipe options',
    optionsSuggestedPrefix: 'Suggested: ',
    optionsYourDefault: 'Your default',
    optionsPickCountry: 'Pick a country / cuisine',
    optionsCuisinePrefix: 'Cuisine: ',
    optionsGenerate: 'Generate recipes',
    favoritesTitle: 'Saved recipes',
    favoritesEmpty: 'No favorites yet. Bookmark a recipe to see it here.',
    rewardsTitle: 'Rewards',
    rewardsYourSeeds: 'Your Seeds',
    rewardsAvailableCoupons: 'Available coupons',
    learnTitle: 'Learn',
    learnIntro:
        'Quick guides on reading food dates, storing smart, and wasting less.',
    learnRegionPrefix: 'Region: ',
    learnRegionUS: 'United States',
    learnRegionEU: 'Europe',
  );

  // ─── Italiano ───────────────────────────────────────────────────────────
  static const AppStrings _it = AppStrings(
    cancel: 'Annulla',
    save: 'Salva',
    delete: 'Elimina',
    edit: 'Modifica',
    back: 'Indietro',
    close: 'Chiudi',
    retry: 'Riprova',
    loading: 'Caricamento…',
    pantryTitle: 'La mia dispensa',
    filterAll: 'Tutti',
    filterExpiring: 'In scadenza',
    filterFresh: 'Freschi',
    noItemsHere: 'Nessun prodotto qui.',
    itemCountOne: 'prodotto',
    itemCountMany: 'prodotti',
    addItem: 'Aggiungi',
    addManually: 'Aggiungi manualmente',
    addManuallySubtitle: 'Compila tu i dettagli del prodotto',
    scanReceipt: 'Scansiona scontrino',
    scanReceiptSubtitle: 'Fai una foto dello scontrino della spesa',
    generateRecipes: 'Genera ricette',
    generating: 'Generazione in corso…',
    noItemsDetected:
        'Nessun prodotto rilevato. Alcuni scontrini non si leggono perfettamente — puoi sempre aggiungerli a mano.',
    receiptScanFailed: 'Scansione scontrino fallita',
    logout: 'Esci',
    navHome: 'Home',
    navRecipes: 'Ricette',
    navLearn: 'Impara',
    navRewards: 'Premi',
    navProfile: 'Profilo',
    scanCapturing: 'Acquisizione scontrino…',
    scanReadingNames: 'Lettura dei nomi…',
    scanDetectingPrices: 'Rilevamento prezzi…',
    scanEstimatingExpiry: 'Stima delle scadenze…',
    scanAlmostDone: 'Quasi fatto…',
    scanning: 'Scansione…',
    scanImperfectNotice:
        'Alcuni scontrini potrebbero non essere letti perfettamente — puoi sempre aggiungere a mano.',
    addItemScreenTitle: 'Aggiungi prodotto',
    editItemScreenTitle: 'Modifica prodotto',
    itemNameLabel: 'Nome prodotto',
    itemNameHint: 'es. Latte intero',
    emojiLabelUpper: 'EMOJI (OPZIONALE)',
    emojiOptionalLabel: '(opzionale)',
    emojiNone: 'Nessuna selezionata',
    categoryLabel: 'Categoria',
    expiryDateLabel: 'Data di scadenza',
    priceAndCurrencyLabel: 'Prezzo e valuta',
    priceHint: 'es. 2.95',
    defaultCurrencyPrefix: 'Predefinita: ',
    addToPantry: 'Aggiungi alla dispensa',
    itemAddedSuccess: 'Prodotto aggiunto',
    itemAddError: 'Errore nell\'aggiungere',
    saveChanges: 'Salva modifiche',
    itemUpdatedSuccess: 'Prodotto aggiornato',
    categoryDairy: 'Latticini',
    categoryVeggies: 'Verdura',
    categoryFruit: 'Frutta',
    categoryProtein: 'Proteine',
    categoryGrains: 'Cereali',
    categoryOther: 'Altro',
    profileTitle: 'Profilo',
    profileYourStats: 'Le tue statistiche',
    profilePoints: 'Punti',
    profileTotalSpent: 'Totale speso',
    profileTotalWasted: 'Totale sprecato',
    profileSettings: 'Impostazioni',
    profileCountryLabel: 'PAESE',
    profileLanguageLabel: 'LINGUA',
    profileReplayTour: 'Rivedi il tour',
    profileCurrencyPrefix: 'Valuta: ',
    loginTitle: 'Accedi',
    loginEmail: 'Email',
    loginPassword: 'Password',
    loginButton: 'Accedi',
    loginRegisterButton: 'Crea account',
    loginFailure: 'Accesso non riuscito',
    recipesTitle: 'Ricette generate',
    recipesBestMatch: 'Miglior abbinamento',
    recipesStepsSuffix: 'passaggi',
    recipesError: 'Errore ricetta',
    detailWatchYoutube: 'Guarda su YouTube',
    detailFindOnline: 'Trova la ricetta online',
    detailFromFridge: 'Dal tuo frigo',
    detailAlsoNeed: 'Ti servirà anche',
    detailSteps: 'Passaggi',
    detailSaveFavorite: 'Salva nei preferiti',
    detailRemoveFavorite: 'Rimuovi dai preferiti',
    consumeIdleNone: 'Nessun prodotto da consumare',
    consumeLoading: 'In corso…',
    consumeCtaPrefix: 'L\'ho cucinato · usa ',
    consumeCtaItemOne: 'prodotto',
    consumeCtaItemMany: 'prodotti',
    consumeDialogTitle: 'Segnare come cucinato?',
    consumeDialogBody: 'Questi prodotti saranno consumati:',
    consumeDialogConfirm: 'Consuma',
    consumeSuccessOne: 'Consumato 1 prodotto. Buon appetito!',
    consumeSuccessMany: 'Consumati {n} prodotti. Buon appetito!',
    consumeFailure: 'Impossibile consumare i prodotti',
    optionsTitle: 'Opzioni ricette',
    optionsSuggestedPrefix: 'Consigliata: ',
    optionsYourDefault: 'La tua preferita',
    optionsPickCountry: 'Scegli paese / cucina',
    optionsCuisinePrefix: 'Cucina: ',
    optionsGenerate: 'Genera ricette',
    favoritesTitle: 'Ricette salvate',
    favoritesEmpty:
        'Nessun preferito. Salva una ricetta con il segnalibro per vederla qui.',
    rewardsTitle: 'Premi',
    rewardsYourSeeds: 'I tuoi Semi',
    rewardsAvailableCoupons: 'Coupon disponibili',
    learnTitle: 'Impara',
    learnIntro:
        'Guide veloci su etichette, conservazione intelligente e meno sprechi.',
    learnRegionPrefix: 'Regione: ',
    learnRegionUS: 'Stati Uniti',
    learnRegionEU: 'Europa',
  );
}
