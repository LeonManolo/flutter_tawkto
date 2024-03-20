/// Use [TawkVisitor] to set the visitor name and email.
class TawkVisitor {
  /// Visitor's name.
  final String? name;

  /// Visitor's email.
  final String? email;

  /// [Secure mode](https://developer.tawk.to/jsapi/#SecureMode).
  final String? hash;

  /// Defines a map of additional custom attributes to be used with the Tawk.to setAttributes API.
  ///
  /// Each entry in this map represents a custom attribute where:
  /// - The key is a `String` that adheres to specific formatting rules: it must be alphanumeric
  ///   and can include dashes ('-'). For example, "user-id" and "age-range" are valid keys.
  /// - The value is dynamic, but only primitive data types work.
  ///
  /// IMPORTANT Usage Notes:
  /// - Ensure that the key-value pairs conform to the constraints expected by the Tawk.to API.
  ///   Refer to the official documentation for `setAttributes` at https://developer.tawk.to/jsapi/#setAttributes.
  /// - BE AWARE that the key used when creating a new custom attribute in the Tawk.to settings
  ///   (under settings/contact-attributes) may not persist as expected. After defining a new
  ///   custom attribute, it is crucial to edit it immediately to note the automatically generated
  ///   key, which typically appears in a format similar to "be14rgec-v". This key is what should
  ///   be used within your Dart code to ensure the correct association of attributes.
  ///
  final Map<String, dynamic> additionalAttributes;

  TawkVisitor({
    this.name,
    this.email,
    this.hash,
    this.additionalAttributes = const {},
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (name != null) {
      data['name'] = name;
    }

    if (email != null) {
      data['email'] = email;
    }

    if (hash != null) {
      data['hash'] = hash;
    }

    return {...data, ...additionalAttributes};
  }
}
