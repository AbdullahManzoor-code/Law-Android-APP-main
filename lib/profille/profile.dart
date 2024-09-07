import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:law_app/Orders/user_orders_page.dart';
import 'package:law_app/auth/auth_page.dart';
import 'package:law_app/components/common/ipinfo.dart';
import 'package:law_app/components/common/round_button.dart';
import 'package:law_app/components/common/timer.dart';
import 'package:law_app/components/toaster.dart';
import '../components/common/uploadtask.dart';

  String? selectedCurrency="USD - United States Dollar";
class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ImagePicker picker = ImagePicker();
  File? image;
  final user = FirebaseAuth.instance.currentUser;

  // Form Key
  final _formKey = GlobalKey<FormState>();

  TextEditingController txtName = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtMobile = TextEditingController();
  TextEditingController txtAddress = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  TextEditingController txtConfirmPassword = TextEditingController();

  bool loading = false;

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
    }
  }

  Future<void> saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        loading = true;
      });

      try {
        if (user != null) {
          final userId = user!.uid;

          // Update display name
          if (txtName.text.isNotEmpty) {
            await user!.updateDisplayName(txtName.text.trim());
          }

          // Update Firestore database
          await FirebaseFirestore.instance.collection('users').doc(userId).update({
            'name': txtName.text.trim(),
            'phone': txtMobile.text.trim(),
            'email': txtEmail.text.trim(),
            'currency':selectedCurrency
          });

          if (image != null) {
            final downloadUrl = await storeToFirebase(image!, "image/profilepic/$userId");
            await FirebaseAuth.instance.currentUser?.updatePhotoURL(downloadUrl);
            await FirebaseFirestore.instance.collection('users').doc(userId).update({
              'profilepic': downloadUrl,
            });
          }

          showToast(message: "Profile Updated Successfully");
        }
      } catch (e) {
        showToast(message: "Failed to Update Profile: $e");
      } finally {
        setState(() {
          loading = false;
        });
      }
    } else {
      showToast(message: "Please correct the errors in the form.");
    }
  }

  @override
  void initState() {
    super.initState();
    getProfileData();
  }

  Country? country;
  pickCountry() {
    showCountryPicker(
        context: context,
        onSelect: (Country country) {
          setState(() {
            this.country = country;
          });
        });
  }

  Future<void> getProfileData() async {
    if (user != null) {
      final userId = user!.uid;
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

        if (doc.exists) {
          setState(() {
            txtName.text = doc['name'] ?? '';
            txtEmail.text = doc['email'] ?? '';
            txtMobile.text = doc['phone'] ?? '';
          });
        } else {
          showToast(message: "No Profile Data Found");
        }
      } catch (e) {
        showToast(message: "Failed to Fetch Profile Data: $e");
      }
    }
  }

  final List<String> currencies = [
    'USD - United States Dollar',
    'EUR - Euro',
    'GBP - British Pound',
    'JPY - Japanese Yen',
    'AUD - Australian Dollar',
    'CAD - Canadian Dollar',
    'CHF - Swiss Franc',
    'CNY - Chinese Yuan',
    'SEK - Swedish Krona',
    'NZD - New Zealand Dollar',
    'MXN - Mexican Peso',
    'SGD - Singapore Dollar',
    'HKD - Hong Kong Dollar',
    'NOK - Norwegian Krone',
    'KRW - South Korean Won',
    'TRY - Turkish Lira',
    'INR - Indian Rupee',
    'RUB - Russian Ruble',
    'BRL - Brazilian Real',
    'ZAR - South African Rand',
    'PLN - Polish Zloty',
    'DKK - Danish Krone',
    'TWD - New Taiwan Dollar',
    'THB - Thai Baht',
    'MYR - Malaysian Ringgit',
    'IDR - Indonesian Rupiah',
    'PHP - Philippine Peso',
    'VND - Vietnamese Dong',
    'EGP - Egyptian Pound',
    'SAR - Saudi Riyal',
    'AED - United Arab Emirates Dirham',
    'ARS - Argentine Peso',
    'CLP - Chilean Peso',
    'COP - Colombian Peso',
    'PEN - Peruvian Sol',
    'PKR - Pakistani Rupee',
    'ILS - Israeli New Shekel',
    'QAR - Qatari Riyal',
    'OMR - Omani Rial',
    'KWD - Kuwaiti Dinar',
    'BHD - Bahraini Dinar',
    'NGN - Nigerian Naira',
    'GHS - Ghanaian Cedi',
    'KES - Kenyan Shilling',
    'UGX - Ugandan Shilling',
    'TZS - Tanzanian Shilling',
    'XAF - Central African CFA Franc',
    'XOF - West African CFA Franc',
    'MAD - Moroccan Dirham',
    'DZD - Algerian Dinar',
    'TND - Tunisian Dinar',
    'LBP - Lebanese Pound',
    'JOD - Jordanian Dinar',
    'BND - Brunei Dollar',
    'BDT - Bangladeshi Taka',
    'LKR - Sri Lankan Rupee',
    'NPR - Nepalese Rupee',
    'MMK - Myanmar Kyat',
    'KHR - Cambodian Riel',
    'LAK - Lao Kip',
    'MNT - Mongolian Tugrik',
    'KZT - Kazakhstani Tenge',
    'UZS - Uzbekistani Som',
    'AZN - Azerbaijani Manat',
    'GEL - Georgian Lari',
    'AMD - Armenian Dram',
    'BYN - Belarusian Ruble',
    'UAH - Ukrainian Hryvnia',
    'KGS - Kyrgyzstani Som',
    'AFN - Afghan Afghani',
    'IRR - Iranian Rial',
    'IQD - Iraqi Dinar',
    'SYP - Syrian Pound',
    'YER - Yemeni Rial',
    'LBP - Lebanese Pound',
    'SOS - Somali Shilling',
    'ETB - Ethiopian Birr',
    'ZMW - Zambian Kwacha',
    'MWK - Malawian Kwacha',
    'MZN - Mozambican Metical',
    'AOA - Angolan Kwanza',
    'BWP - Botswana Pula',
    'NAD - Namibian Dollar',
    'ZWL - Zimbabwean Dollar',
    'BBD - Barbadian Dollar',
    'BMD - Bermudian Dollar',
    'BZD - Belize Dollar',
    'JMD - Jamaican Dollar',
    'TTD - Trinidad and Tobago Dollar',
    'XCD - East Caribbean Dollar',
    'BSD - Bahamian Dollar',
    'FJD - Fijian Dollar',
    'PGK - Papua New Guinean Kina',
    'SBD - Solomon Islands Dollar',
    'VUV - Vanuatu Vatu',
    'WST - Samoan Tala',
    'TOP - Tongan Paʻanga',
    'KPW - North Korean Won',
    'MOP - Macanese Pataca',
    'CUP - Cuban Peso',
    'DOP - Dominican Peso',
    'HTG - Haitian Gourde',
    'PYG - Paraguayan Guarani',
    'UYU - Uruguayan Peso',
    'FKP - Falkland Islands Pound',
    'GIP - Gibraltar Pound',
    'SHP - Saint Helena Pound',
    'IMP - Isle of Man Pound',
    'JEP - Jersey Pound',
    'GGP - Guernsey Pound',
    'BIF - Burundian Franc',
    'CVE - Cape Verdean Escudo',
    'DJF - Djiboutian Franc',
    'GNF - Guinean Franc',
    'KMF - Comorian Franc',
    'RWF - Rwandan Franc',
    'SCR - Seychellois Rupee',
    'STD - São Tomé and Príncipe Dobra',
    'CDF - Congolese Franc',
    'SSP - South Sudanese Pound',
    'SZL - Eswatini Lilangeni',
    'LSL - Lesotho Loti',
    'MGA - Malagasy Ariary',
    'ERN - Eritrean Nakfa',
    'MWK - Malawian Kwacha',
    'MUR - Mauritian Rupee',
    'NIO - Nicaraguan Córdoba',
    'BTN - Bhutanese Ngultrum',
    'BND - Brunei Dollar',
];


  @override
  Widget build(BuildContext context) {
    return IdleTimeoutWrapper(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OrderPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.receipt),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AuthPage()));
                      },
                      icon: const Icon(
                        Icons.logout,
                        size: 20,
                      ),
                      label: const Text(
                        "Logout",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(50),
                  ),
                  alignment: Alignment.center,
                  child: image == null && user?.photoURL != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(
                            user!.photoURL!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        )
                      : image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.file(
                                File(image!.path),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 65,
                              color: Colors.grey,
                            ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    pickImage();
                  },
                  icon: const Icon(
                    Icons.edit,
                    size: 12,
                  ),
                  label: const Text(
                    "Edit Profile",
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                const Text(
                  "Hi there!",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextFormField(
                        controller: txtName,
                        decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF11CEC4))),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF11CEC4))),
                          labelText: 'Name',
                          labelStyle: TextStyle(color: Color(0xFF11CEC4)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Name cannot be empty';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextFormField(
                        controller: txtEmail,
                        decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF11CEC4))),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF11CEC4))),
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Color(0xFF11CEC4)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email field cannot be empty';
                          }
                          final emailRegex = RegExp(
                              r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
                          if (!emailRegex.hasMatch(value)) {
                            return 'Invalid Email';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: pickCountry,
                      child: const Text("Pick your country"),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller:txtMobile ,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          enabledBorder: const UnderlineInputBorder(
                              borderSide: const BorderSide(color: Color(0xFF11CEC4))),
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF11CEC4))),
                          labelText: 'Phone',
                          labelStyle: const TextStyle(color: Color(0xFF11CEC4)),
                          hintText: 'Enter your WhatsApp number',
                          prefixIcon: const Icon(
                            Icons.phone,
                            color: Color(0xFF11CEC4),
                          ),
                          prefixText: (country != null)
                              ? "+${country!.phoneCode}  "
                              : null,
                        ),
                        validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your WhatsApp number';
                        }
                      
                        // Check if the phone number starts with zero
                        if (value.startsWith('0')) {
                          return 'Phone number cannot start with zero';
                        }
                      
                        // Define valid country codes and their corresponding length ranges and patterns
                        final validCountries = {
                          'GB': {'name': 'England', 'minLength': 10, 'maxLength': 10, 'pattern': '#### ######'}, // England (UK)
                          'US': {'name': 'USA', 'minLength': 10, 'maxLength': 10, 'pattern': '(###) ###-####'},     // USA
                          'DE': {'name': 'Germany', 'minLength': 10, 'maxLength': 11, 'pattern': '#### ### ####'}, // Germany
                          'FR': {'name': 'France', 'minLength': 9, 'maxLength': 9, 'pattern': '## ## ## ##'},    // France
                          'SE': {'name': 'Sweden', 'minLength': 9, 'maxLength': 9, 'pattern': '###-### ###'},    // Sweden
                          'PK': {'name': 'Pakistan', 'minLength': 10, 'maxLength': 10, 'pattern': '###-#######'}, // Pakistan
                        };
                      
                        // Check if the country is selected and valid
                        if (country == null || !validCountries.containsKey(country!.countryCode)) {
                          return 'Please select a valid country';
                        }
                      
                        // Validate phone number length for the selected country
                        final countrySettings = validCountries[country!.countryCode]!;
                        final phoneNumberLength = value.length;
                      
                        if (phoneNumberLength <int.parse( countrySettings['minLength'].toString() )|| 
                            phoneNumberLength >int.parse( countrySettings['maxLength'].toString())) {
                          return 'Phone number must be ${countrySettings['minLength']} digits for ${countrySettings['name']}';
                        }
                      
                        // Format phone number based on the pattern
                        final pattern = countrySettings['pattern']!;
                        int index = 0;
                      
                        for (int i = 0; i < pattern.toString().length; i++) {
                          if (pattern.toString()[i] == '-') {
                            if (index < value.length) {
                            }
                          } else {
                          }
                        }
                      
                        return null;
                      },
                      
                      
                      ),
                    ),
                Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Preferred Currency",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedCurrency,
              items: currencies.map((String currency) {
                return DropdownMenuItem<String>(
                  value: currency,
                  child: Text(currency),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCurrency = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                hintText: "Select Currency",
              ),
            ),
            
          ],
        ),
      ),
                const SizedBox(height: 20),
                loading
                    ? const CircularProgressIndicator(color: Color(0xFF11CEC4))
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: RoundButton(
                          title: "Save",
                          onPressed: () async {
                            saveProfile();
                          },
                        ),
                      ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
