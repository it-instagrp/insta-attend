class CountryCode {
  String countryName;
  String countryCode;
  String phoneDigits; // Expected digit length for validation

  CountryCode({
    required this.countryName,
    required this.countryCode,
    required this.phoneDigits,
  });
}

// TODO: Replace with backend API call when country data management is ready
class CountryCodeHelper {
  static List<CountryCode> getAllCountries() {
    return [
      CountryCode(
        countryName: 'India',
        countryCode: '+91',
        phoneDigits: '10',
      ),
      CountryCode(
        countryName: 'United States',
        countryCode: '+1',
        phoneDigits: '10',
      ),
      CountryCode(
        countryName: 'United Kingdom',
        countryCode: '+44',
        phoneDigits: '10',
      ),
      CountryCode(
        countryName: 'Australia',
        countryCode: '+61',
        phoneDigits: '9',
      ),
      CountryCode(
        countryName: 'Canada',
        countryCode: '+1',
        phoneDigits: '10',
      ),
      CountryCode(
        countryName: 'Germany',
        countryCode: '+49',
        phoneDigits: '11',
      ),
      CountryCode(
        countryName: 'France',
        countryCode: '+33',
        phoneDigits: '9',
      ),
      CountryCode(
        countryName: 'Japan',
        countryCode: '+81',
        phoneDigits: '10',
      ),
      CountryCode(
        countryName: 'Singapore',
        countryCode: '+65',
        phoneDigits: '8',
      ),
      CountryCode(
        countryName: 'UAE',
        countryCode: '+971',
        phoneDigits: '9',
      ),
    ];
  }

  static CountryCode? getCountryByCode(String code) {
    try {
      return getAllCountries().firstWhere(
            (country) => country.countryCode == code,
      );
    } catch (e) {
      return null;
    }
  }
}