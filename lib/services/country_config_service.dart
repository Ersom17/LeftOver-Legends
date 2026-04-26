// lib/services/country_config_service.dart
// Maps countries to their default currencies and cultures for recipes

class CountryConfig {
  final String currency;
  final String culture;

  const CountryConfig({
    required this.currency,
    required this.culture,
  });
}

class CountryConfigService {
  static const Map<String, CountryConfig> countryConfigs = {
    // Europe
    'Austria': CountryConfig(currency: 'EUR', culture: 'Austrian'),
    'Belgium': CountryConfig(currency: 'EUR', culture: 'French'),
    'Bulgaria': CountryConfig(currency: 'BGN', culture: 'Bulgarian'),
    'Croatia': CountryConfig(currency: 'HRK', culture: 'Croatian'),
    'Cyprus': CountryConfig(currency: 'EUR', culture: 'Greek'),
    'Czech Republic': CountryConfig(currency: 'CZK', culture: 'Czech'),
    'Denmark': CountryConfig(currency: 'DKK', culture: 'Scandinavian'),
    'Estonia': CountryConfig(currency: 'EUR', culture: 'Baltic'),
    'Finland': CountryConfig(currency: 'EUR', culture: 'Scandinavian'),
    'France': CountryConfig(currency: 'EUR', culture: 'French'),
    'Germany': CountryConfig(currency: 'EUR', culture: 'German'),
    'Greece': CountryConfig(currency: 'EUR', culture: 'Greek'),
    'Hungary': CountryConfig(currency: 'HUF', culture: 'Hungarian'),
    'Iceland': CountryConfig(currency: 'ISK', culture: 'Scandinavian'),
    'Ireland': CountryConfig(currency: 'EUR', culture: 'Irish'),
    'Italy': CountryConfig(currency: 'EUR', culture: 'Italian'),
    'Latvia': CountryConfig(currency: 'EUR', culture: 'Baltic'),
    'Lithuania': CountryConfig(currency: 'EUR', culture: 'Baltic'),
    'Luxembourg': CountryConfig(currency: 'EUR', culture: 'French'),
    'Malta': CountryConfig(currency: 'EUR', culture: 'Mediterranean'),
    'Netherlands': CountryConfig(currency: 'EUR', culture: 'Dutch'),
    'Norway': CountryConfig(currency: 'NOK', culture: 'Scandinavian'),
    'Poland': CountryConfig(currency: 'PLN', culture: 'Polish'),
    'Portugal': CountryConfig(currency: 'EUR', culture: 'Portuguese'),
    'Romania': CountryConfig(currency: 'RON', culture: 'Romanian'),
    'Russia': CountryConfig(currency: 'RUB', culture: 'Russian'),
    'Slovakia': CountryConfig(currency: 'EUR', culture: 'Slovak'),
    'Slovenia': CountryConfig(currency: 'EUR', culture: 'Slovenian'),
    'Spain': CountryConfig(currency: 'EUR', culture: 'Spanish'),
    'Sweden': CountryConfig(currency: 'SEK', culture: 'Scandinavian'),
    'Switzerland': CountryConfig(currency: 'CHF', culture: 'Swiss'),
    'Turkey': CountryConfig(currency: 'TRY', culture: 'Turkish'),
    'Ukraine': CountryConfig(currency: 'UAH', culture: 'Ukrainian'),
    'United Kingdom': CountryConfig(currency: 'GBP', culture: 'British'),

    // Asia
    'Afghanistan': CountryConfig(currency: 'AFN', culture: 'Afghan'),
    'Bangladesh': CountryConfig(currency: 'BDT', culture: 'Bengali'),
    'Bhutan': CountryConfig(currency: 'BTN', culture: 'Bhutanese'),
    'Cambodia': CountryConfig(currency: 'KHR', culture: 'Cambodian'),
    'China': CountryConfig(currency: 'CNY', culture: 'Chinese'),
    'Georgia': CountryConfig(currency: 'GEL', culture: 'Georgian'),
    'Hong Kong': CountryConfig(currency: 'HKD', culture: 'Chinese'),
    'India': CountryConfig(currency: 'INR', culture: 'Indian'),
    'Indonesia': CountryConfig(currency: 'IDR', culture: 'Indonesian'),
    'Iran': CountryConfig(currency: 'IRR', culture: 'Persian'),
    'Iraq': CountryConfig(currency: 'IQD', culture: 'Middle Eastern'),
    'Israel': CountryConfig(currency: 'ILS', culture: 'Middle Eastern'),
    'Japan': CountryConfig(currency: 'JPY', culture: 'Japanese'),
    'Jordan': CountryConfig(currency: 'JOD', culture: 'Middle Eastern'),
    'Kazakhstan': CountryConfig(currency: 'KZT', culture: 'Central Asian'),
    'Kuwait': CountryConfig(currency: 'KWD', culture: 'Middle Eastern'),
    'Kyrgyzstan': CountryConfig(currency: 'KGS', culture: 'Central Asian'),
    'Laos': CountryConfig(currency: 'LAK', culture: 'Southeast Asian'),
    'Lebanon': CountryConfig(currency: 'LBP', culture: 'Middle Eastern'),
    'Malaysia': CountryConfig(currency: 'MYR', culture: 'Southeast Asian'),
    'Mongolia': CountryConfig(currency: 'MNT', culture: 'Mongolian'),
    'Myanmar': CountryConfig(currency: 'MMK', culture: 'Southeast Asian'),
    'Nepal': CountryConfig(currency: 'NPR', culture: 'Nepali'),
    'North Korea': CountryConfig(currency: 'KPW', culture: 'Korean'),
    'Oman': CountryConfig(currency: 'OMR', culture: 'Middle Eastern'),
    'Pakistan': CountryConfig(currency: 'PKR', culture: 'Pakistani'),
    'Palestine': CountryConfig(currency: 'ILS', culture: 'Middle Eastern'),
    'Philippines': CountryConfig(currency: 'PHP', culture: 'Filipino'),
    'Qatar': CountryConfig(currency: 'QAR', culture: 'Middle Eastern'),
    'Saudi Arabia': CountryConfig(currency: 'SAR', culture: 'Middle Eastern'),
    'Singapore': CountryConfig(currency: 'SGD', culture: 'Southeast Asian'),
    'South Korea': CountryConfig(currency: 'KRW', culture: 'Korean'),
    'Syria': CountryConfig(currency: 'SYP', culture: 'Middle Eastern'),
    'Taiwan': CountryConfig(currency: 'TWD', culture: 'Chinese'),
    'Tajikistan': CountryConfig(currency: 'TJS', culture: 'Central Asian'),
    'Thailand': CountryConfig(currency: 'THB', culture: 'Thai'),
    'Timor-Leste': CountryConfig(currency: 'USD', culture: 'Southeast Asian'),
    'Turkmenistan': CountryConfig(currency: 'TMT', culture: 'Central Asian'),
    'United Arab Emirates': CountryConfig(currency: 'AED', culture: 'Middle Eastern'),
    'Uzbekistan': CountryConfig(currency: 'UZS', culture: 'Central Asian'),
    'Vietnam': CountryConfig(currency: 'VND', culture: 'Vietnamese'),
    'Yemen': CountryConfig(currency: 'YER', culture: 'Middle Eastern'),

    // Africa
    'Algeria': CountryConfig(currency: 'DZD', culture: 'North African'),
    'Angola': CountryConfig(currency: 'AOA', culture: 'African'),
    'Benin': CountryConfig(currency: 'XOF', culture: 'West African'),
    'Botswana': CountryConfig(currency: 'BWP', culture: 'African'),
    'Burkina Faso': CountryConfig(currency: 'XOF', culture: 'West African'),
    'Burundi': CountryConfig(currency: 'BIF', culture: 'African'),
    'Cameroon': CountryConfig(currency: 'XAF', culture: 'Central African'),
    'Cape Verde': CountryConfig(currency: 'CVE', culture: 'African'),
    'Central African Republic': CountryConfig(currency: 'XAF', culture: 'Central African'),
    'Chad': CountryConfig(currency: 'XAF', culture: 'Central African'),
    'Comoros': CountryConfig(currency: 'KMF', culture: 'African'),
    'Congo': CountryConfig(currency: 'XAF', culture: 'Central African'),
    'Djibouti': CountryConfig(currency: 'DJF', culture: 'East African'),
    'Egypt': CountryConfig(currency: 'EGP', culture: 'Middle Eastern'),
    'Equatorial Guinea': CountryConfig(currency: 'XAF', culture: 'Central African'),
    'Eritrea': CountryConfig(currency: 'ERN', culture: 'East African'),
    'Eswatini': CountryConfig(currency: 'SZL', culture: 'African'),
    'Ethiopia': CountryConfig(currency: 'ETB', culture: 'East African'),
    'Gabon': CountryConfig(currency: 'XAF', culture: 'Central African'),
    'Gambia': CountryConfig(currency: 'GMD', culture: 'West African'),
    'Ghana': CountryConfig(currency: 'GHS', culture: 'West African'),
    'Guinea': CountryConfig(currency: 'GNF', culture: 'West African'),
    'Guinea-Bissau': CountryConfig(currency: 'XOF', culture: 'West African'),
    'Kenya': CountryConfig(currency: 'KES', culture: 'East African'),
    'Lesotho': CountryConfig(currency: 'LSL', culture: 'African'),
    'Liberia': CountryConfig(currency: 'LRD', culture: 'West African'),
    'Libya': CountryConfig(currency: 'LYD', culture: 'North African'),
    'Madagascar': CountryConfig(currency: 'MGA', culture: 'African'),
    'Malawi': CountryConfig(currency: 'MWK', culture: 'African'),
    'Mali': CountryConfig(currency: 'XOF', culture: 'West African'),
    'Mauritania': CountryConfig(currency: 'MRU', culture: 'North African'),
    'Mauritius': CountryConfig(currency: 'MUR', culture: 'African'),
    'Morocco': CountryConfig(currency: 'MAD', culture: 'North African'),
    'Mozambique': CountryConfig(currency: 'MZN', culture: 'African'),
    'Namibia': CountryConfig(currency: 'NAD', culture: 'African'),
    'Niger': CountryConfig(currency: 'XOF', culture: 'West African'),
    'Nigeria': CountryConfig(currency: 'NGN', culture: 'West African'),
    'Rwanda': CountryConfig(currency: 'RWF', culture: 'East African'),
    'Senegal': CountryConfig(currency: 'XOF', culture: 'West African'),
    'Seychelles': CountryConfig(currency: 'SCR', culture: 'African'),
    'Sierra Leone': CountryConfig(currency: 'SLL', culture: 'West African'),
    'Somalia': CountryConfig(currency: 'SOS', culture: 'East African'),
    'South Africa': CountryConfig(currency: 'ZAR', culture: 'African'),
    'South Sudan': CountryConfig(currency: 'SSP', culture: 'East African'),
    'Sudan': CountryConfig(currency: 'SDG', culture: 'East African'),
    'Tanzania': CountryConfig(currency: 'TZS', culture: 'East African'),
    'Togo': CountryConfig(currency: 'XOF', culture: 'West African'),
    'Tunisia': CountryConfig(currency: 'TND', culture: 'North African'),
    'Uganda': CountryConfig(currency: 'UGX', culture: 'East African'),
    'Zambia': CountryConfig(currency: 'ZMW', culture: 'African'),
    'Zimbabwe': CountryConfig(currency: 'ZWL', culture: 'African'),

    // Americas
    'Argentina': CountryConfig(currency: 'ARS', culture: 'South American'),
    'Bahamas': CountryConfig(currency: 'BSD', culture: 'Caribbean'),
    'Barbados': CountryConfig(currency: 'BBD', culture: 'Caribbean'),
    'Belize': CountryConfig(currency: 'BZD', culture: 'Central American'),
    'Bolivia': CountryConfig(currency: 'BOB', culture: 'South American'),
    'Brazil': CountryConfig(currency: 'BRL', culture: 'Brazilian'),
    'Canada': CountryConfig(currency: 'CAD', culture: 'North American'),
    'Chile': CountryConfig(currency: 'CLP', culture: 'South American'),
    'Colombia': CountryConfig(currency: 'COP', culture: 'South American'),
    'Costa Rica': CountryConfig(currency: 'CRC', culture: 'Central American'),
    'Cuba': CountryConfig(currency: 'CUP', culture: 'Caribbean'),
    'Dominican Republic': CountryConfig(currency: 'DOP', culture: 'Caribbean'),
    'Ecuador': CountryConfig(currency: 'USD', culture: 'South American'),
    'El Salvador': CountryConfig(currency: 'USD', culture: 'Central American'),
    'Grenada': CountryConfig(currency: 'XCD', culture: 'Caribbean'),
    'Guatemala': CountryConfig(currency: 'GTQ', culture: 'Central American'),
    'Guyana': CountryConfig(currency: 'GYD', culture: 'South American'),
    'Haiti': CountryConfig(currency: 'HTG', culture: 'Caribbean'),
    'Honduras': CountryConfig(currency: 'HNL', culture: 'Central American'),
    'Jamaica': CountryConfig(currency: 'JMD', culture: 'Caribbean'),
    'Mexico': CountryConfig(currency: 'MXN', culture: 'Mexican'),
    'Nicaragua': CountryConfig(currency: 'NIO', culture: 'Central American'),
    'Panama': CountryConfig(currency: 'USD', culture: 'Central American'),
    'Paraguay': CountryConfig(currency: 'PYG', culture: 'South American'),
    'Peru': CountryConfig(currency: 'PEN', culture: 'Peruvian'),
    'Saint Kitts and Nevis': CountryConfig(currency: 'XCD', culture: 'Caribbean'),
    'Saint Lucia': CountryConfig(currency: 'XCD', culture: 'Caribbean'),
    'Saint Vincent and the Grenadines': CountryConfig(currency: 'XCD', culture: 'Caribbean'),
    'Suriname': CountryConfig(currency: 'SRD', culture: 'South American'),
    'Trinidad and Tobago': CountryConfig(currency: 'TTD', culture: 'Caribbean'),
    'United States': CountryConfig(currency: 'USD', culture: 'American'),
    'Uruguay': CountryConfig(currency: 'UYU', culture: 'South American'),
    'Venezuela': CountryConfig(currency: 'VES', culture: 'South American'),

    // Oceania
    'Australia': CountryConfig(currency: 'AUD', culture: 'Australian'),
    'Fiji': CountryConfig(currency: 'FJD', culture: 'Pacific'),
    'Kiribati': CountryConfig(currency: 'AUD', culture: 'Pacific'),
    'Marshall Islands': CountryConfig(currency: 'USD', culture: 'Pacific'),
    'Micronesia': CountryConfig(currency: 'USD', culture: 'Pacific'),
    'Nauru': CountryConfig(currency: 'AUD', culture: 'Pacific'),
    'New Zealand': CountryConfig(currency: 'NZD', culture: 'Pacific'),
    'Palau': CountryConfig(currency: 'USD', culture: 'Pacific'),
    'Papua New Guinea': CountryConfig(currency: 'PGK', culture: 'Pacific'),
    'Samoa': CountryConfig(currency: 'WST', culture: 'Pacific'),
    'Solomon Islands': CountryConfig(currency: 'SBD', culture: 'Pacific'),
    'Tonga': CountryConfig(currency: 'TOP', culture: 'Pacific'),
    'Tuvalu': CountryConfig(currency: 'AUD', culture: 'Pacific'),
    'Vanuatu': CountryConfig(currency: 'VUV', culture: 'Pacific'),

    // Default fallback
    'Other': CountryConfig(currency: 'USD', culture: 'American'),
  };

  /// Get currency for a country
  static String getCurrency(String country) {
    return countryConfigs[country]?.currency ?? 'USD';
  }

  /// Get default culture for recipe generation
  static String getCulture(String country) {
    return countryConfigs[country]?.culture ?? 'American';
  }

  /// Get both currency and culture
  static CountryConfig getConfig(String country) {
    return countryConfigs[country] ?? const CountryConfig(
      currency: 'USD',
      culture: 'American',
    );
  }

  static List<String> getAllCultures() {
    final cultures = countryConfigs.values
        .map((config) => config.culture)
        .toSet()
        .toList();

    cultures.sort();

    return cultures;
  }
}
