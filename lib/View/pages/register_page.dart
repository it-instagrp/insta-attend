import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:insta_attend/Component/Button/main_button.dart';
import 'package:insta_attend/Constant/constant_asset.dart';
import 'package:insta_attend/Constant/constant_color.dart';
import 'package:insta_attend/Controller/auth_controller.dart';
import 'package:insta_attend/Model/organization.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}
class _RegisterPageState extends State<RegisterPage> {
  final AuthController controller = Get.find<AuthController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Timer? _debounceTimer;
  final FocusNode _orgFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final TextStyle _fieldTitleStyle = const TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  final OutlineInputBorder _enabledBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: kcGrey300, width: 1.0),
  );

  final OutlineInputBorder _focusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: kcPurple600, width: 1.5),
  );

  final OutlineInputBorder _errorBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: Colors.red, width: 1.0),
  );

  final OutlineInputBorder _focusedErrorBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: Colors.red, width: 1.5),
  );

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _orgFocusNode.dispose();
    controller.selectedOrganization.value = null;
    controller.organizationList.clear();
    super.dispose();
  }

  int _getPhoneLengthForCountry(String? code) {
    switch (code) {
      case '+91': // India
        return 10;
      case '+1': // USA / Canada
        return 10;
      case '+86': // China
        return 11;
      case '+81': // Japan
        return 10;
      case '+82': // South Korea
        return 10;
      case '+44': // UK
        return 10;
      case '+33': // France
        return 9;
      case '+49': // Germany
        return 11;
      case '+61': // Australia
        return 9;
      case '+971': // UAE
        return 9;
      case '+966': // Saudi Arabia
        return 9;
      case '+65': // Singapore
        return 8;
      case '+60': // Malaysia
        return 9;
      default:
        return 10;
    }
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final selectedCode = controller.selectedCountryCode.value?['code'];
    final requiredLength = _getPhoneLengthForCountry(selectedCode);
    final cleanValue = value.trim();

    if (!RegExp(r'^[0-9]+$').hasMatch(cleanValue)) {
      return 'Enter valid digits only';
    }

    if (cleanValue.length != requiredLength) {
      return 'Phone number must be exactly $requiredLength digits for $selectedCode';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildHeader(),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: kcGrey300.withValues(alpha: 0.5)),
                      ),
                      child: _buildForm(context),
                    ),
                  ],
                ),
              ),
            ),
            _buildBackButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrganizationSelector(context),
          const SizedBox(height: 16),
          _buildNameField(),
          const SizedBox(height: 16),
          _buildEmailField(),
          const SizedBox(height: 16),
          _buildPhoneNumberField(),
          const SizedBox(height: 16),
          _buildPasswordFieldWithTooltip(),
          const SizedBox(height: 16),
          _buildConfirmPasswordField(),
          const SizedBox(height: 24),
          _buildRegisterButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        SvgPicture.asset(
          kaLogo,
          fit: BoxFit.scaleDown,
          height: 52,
          width: 52,
        ),
        const SizedBox(height: 12),
        const Text(
          "InstaAttend",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Create your account to get started",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: kcGrey500,
          ),
        ),
      ],
    );
  }

  Widget _buildOrganizationSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Organization', style: _fieldTitleStyle),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            return RawAutocomplete<Organization>(
              displayStringForOption: (option) => option.name ?? '',
              optionsBuilder: (TextEditingValue textEditingValue) {
                final query = textEditingValue.text.trim();

                if (query.length < 3) {
                  controller.organizationList.clear();
                  return const Iterable<Organization>.empty();
                }

                final completer = Completer<Iterable<Organization>>();
                _debounceTimer?.cancel();

                _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
                  await controller.searchOrganizations(query);
                  completer.complete(controller.organizationList.cast<Organization>());
                });

                return completer.future;
              },
              onSelected: (option) {
                controller.selectedOrganization.value = option;
                FocusScope.of(context).unfocus();
              },
              fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                return TextFormField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  style: const TextStyle(fontSize: 13, color: Colors.black),
                  validator: (value) {
                    if (controller.selectedOrganization.value == null) {
                      return 'Please select an organization';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Search or select organization...',
                    hintStyle: TextStyle(color: kcGrey400, fontSize: 13),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SvgPicture.asset(
                        kaOrg,
                        width: 18,
                        height: 18,
                        colorFilter: ColorFilter.mode(kcPurple800, BlendMode.srcIn),
                      ),
                    ),
                    suffixIcon: Obx(() {
                      if (controller.isOrganizationSearchLoading.value) {
                        return UnconstrainedBox(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: kcPurple600,
                            ),
                          ),
                        );
                      }
                      if (textEditingController.text.isNotEmpty) {
                        return IconButton(
                          icon: Icon(Icons.close_rounded, size: 18, color: kcGrey500),
                          onPressed: () {
                            textEditingController.clear();
                            controller.selectedOrganization.value = null;
                            controller.organizationList.clear();
                            _formKey.currentState?.validate();
                          },
                        );
                      }
                      return Icon(Icons.keyboard_arrow_down_rounded, color: kcGrey500);
                    }),
                    enabledBorder: _enabledBorder,
                    focusedBorder: _focusedBorder,
                    errorBorder: _errorBorder,
                    focusedErrorBorder: _focusedErrorBorder,
                  ),
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                if (options.isEmpty) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 6,
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                      child: Container(
                        width: constraints.maxWidth,
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'No organization found',
                          style: TextStyle(fontSize: 13, color: kcGrey500),
                        ),
                      ),
                    ),
                  );
                }
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 6,
                    shadowColor: Colors.black.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                    child: Container(
                      width: constraints.maxWidth,
                      constraints: const BoxConstraints(maxHeight: 220),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: kcGrey300.withValues(alpha: 0.6)),
                      ),
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        separatorBuilder: (_, __) => Divider(height: 1, color: kcGrey300.withValues(alpha: 0.4)),
                        itemBuilder: (BuildContext context, int index) {
                          final option = options.elementAt(index);
                          return ListTile(
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            title: Text(
                              option.name ?? '',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            onTap: () => onSelected(option),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },

            );
          },
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Full Name', style: _fieldTitleStyle),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.usernameController,
          keyboardType: TextInputType.name,
          style: const TextStyle(fontSize: 13, color: Colors.black),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Name is required';
            if (value.trim().length < 2) return 'Name must be at least 2 characters';
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Enter your full name',
            hintStyle: TextStyle(color: kcGrey400, fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SvgPicture.asset(
                kaPerson,
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(kcPurple800, BlendMode.srcIn),
              ),
            ),
            enabledBorder: _enabledBorder,
            focusedBorder: _focusedBorder,
            errorBorder: _errorBorder,
            focusedErrorBorder: _focusedErrorBorder,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Email Address', style: _fieldTitleStyle),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(fontSize: 13, color: Colors.black),
          validator: controller.validateEmail,
          decoration: InputDecoration(
            hintText: 'e.g. name@company.com',
            hintStyle: TextStyle(color: kcGrey400, fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SvgPicture.asset(
                kaEmail,
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(kcPurple800, BlendMode.srcIn),
              ),
            ),
            enabledBorder: _enabledBorder,
            focusedBorder: _focusedBorder,
            errorBorder: _errorBorder,
            focusedErrorBorder: _focusedErrorBorder,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Phone Number', style: _fieldTitleStyle),
        const SizedBox(height: 8),
        Obx(
              () => TextFormField(
            controller: controller.phoneController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(
                _getPhoneLengthForCountry(
                  controller.selectedCountryCode.value?['code'],
                ),
              ),
            ],
            style: const TextStyle(fontSize: 13, color: Colors.black),
            validator: _validatePhoneNumber,
            decoration: InputDecoration(
              hintText: 'Enter phone number',
              hintStyle: TextStyle(color: kcGrey400, fontSize: 13),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              prefixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 8),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<Map<String, String>>(
                      value: controller.selectedCountryCode.value,
                      onChanged: (Map<String, String>? newValue) {
                        controller.selectedCountryCode.value = newValue;
                        controller.phoneController.clear();
                        _formKey.currentState?.validate();
                      },
                      items: controller.countryCodeList.map((country) {
                        return DropdownMenuItem(
                          value: country,
                          child: Text(
                            '${country['code']}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    height: 20,
                    width: 1,
                    color: kcGrey300,
                  ),
                  const SizedBox(width: 10),
                  SvgPicture.asset(
                    kaPhone,
                    width: 18,
                    height: 18,
                    colorFilter: ColorFilter.mode(kcPurple800, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              enabledBorder: _enabledBorder,
              focusedBorder: _focusedBorder,
              errorBorder: _errorBorder,
              focusedErrorBorder: _focusedErrorBorder,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordFieldWithTooltip() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Password', style: _fieldTitleStyle),
            Tooltip(
              message: 'Between 6-15 characters. Special characters recommended.',
              triggerMode: TooltipTriggerMode.tap,
              child: Icon(Icons.info_outline_rounded, size: 16, color: kcGrey500),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.passwordController,
          obscureText: _obscurePassword,
          style: const TextStyle(fontSize: 13, color: Colors.black),
          validator: controller.validatePasswordStrength,
          decoration: InputDecoration(
            hintText: '6-15 characters',
            hintStyle: TextStyle(color: kcGrey400, fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SvgPicture.asset(
                kaPassword,
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(kcPurple800, BlendMode.srcIn),
              ),
            ),
            suffixIcon: IconButton(
              icon: SvgPicture.asset(
                _obscurePassword ? kaNotVisible : kaVisible,
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(kcPurple800, BlendMode.srcIn),
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            enabledBorder: _enabledBorder,
            focusedBorder: _focusedBorder,
            errorBorder: _errorBorder,
            focusedErrorBorder: _focusedErrorBorder,
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Confirm Password', style: _fieldTitleStyle),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          style: const TextStyle(fontSize: 13, color: Colors.black),
          validator: (value) => controller.validateConfirmPassword(
            value,
            controller.passwordController.text,
          ),
          decoration: InputDecoration(
            hintText: 'Re-enter your password',
            hintStyle: TextStyle(color: kcGrey400, fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SvgPicture.asset(
                kaPassword,
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(kcPurple800, BlendMode.srcIn),
              ),
            ),
            suffixIcon: IconButton(
              icon: SvgPicture.asset(
                _obscureConfirmPassword ? kaNotVisible : kaVisible,
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(kcPurple800, BlendMode.srcIn),
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            enabledBorder: _enabledBorder,
            focusedBorder: _focusedBorder,
            errorBorder: _errorBorder,
            focusedErrorBorder: _focusedErrorBorder,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return Align(
      alignment: Alignment.center,
      child: Obx(
            () => controller.isRegisterPageLoading.value
            ? Center(
          child: SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              strokeCap: StrokeCap.round,
              color: kcPurple600,
            ),
          ),
        )
            : MainButton(
          label: 'Register',
          onTap: () {
            if (_formKey.currentState!.validate()) {
              controller.registerWithOrganization(context);
            }
          },
          buttonSize: ButtonSize.xl,
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: 12,
      left: 8,
      child: IconButton(
        icon: SvgPicture.asset(kaBackButton, width: 16, height: 16),
        onPressed: () {
          controller.clearNewRegistrationForm();
          Get.back();
        },
      ),
    );
  }
}