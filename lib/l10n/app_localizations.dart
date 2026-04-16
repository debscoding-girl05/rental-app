import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'LandlordOS'**
  String get appName;

  /// Navigation label for Dashboard
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// Navigation label for Properties
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get navProperties;

  /// Navigation label for Tenants
  ///
  /// In en, this message translates to:
  /// **'Tenants'**
  String get navTenants;

  /// Navigation label for Financials
  ///
  /// In en, this message translates to:
  /// **'Financials'**
  String get navFinancials;

  /// Navigation label for AI
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get navAI;

  /// Sign in button/title
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Sign up button/title
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Forgot password link
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Reset password button
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// Create account button
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Already have account prompt
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// Don't have account prompt
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// Sign in subtitle
  ///
  /// In en, this message translates to:
  /// **'Sign in with your email'**
  String get signInWithEmail;

  /// Sign up subtitle
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createYourAccount;

  /// Email hint text
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// Password hint text
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// Password reset confirmation
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent'**
  String get passwordResetSent;

  /// Email validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get invalidEmail;

  /// Password validation error
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// Password confirmation error
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Full name field label
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// Welcome back greeting
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// Sign out button
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// Single property
  ///
  /// In en, this message translates to:
  /// **'Property'**
  String get property;

  /// Multiple properties
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get properties;

  /// Add property button
  ///
  /// In en, this message translates to:
  /// **'Add Property'**
  String get addProperty;

  /// Edit property button
  ///
  /// In en, this message translates to:
  /// **'Edit Property'**
  String get editProperty;

  /// Delete property button
  ///
  /// In en, this message translates to:
  /// **'Delete Property'**
  String get deleteProperty;

  /// Property type field label
  ///
  /// In en, this message translates to:
  /// **'Property Type'**
  String get propertyType;

  /// Property name field label
  ///
  /// In en, this message translates to:
  /// **'Property Name'**
  String get propertyName;

  /// Address field label
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// Quartier/neighborhood field label
  ///
  /// In en, this message translates to:
  /// **'Quartier'**
  String get quartier;

  /// City field label
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// Country field label
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// Number of floors
  ///
  /// In en, this message translates to:
  /// **'Floors'**
  String get floors;

  /// Multiple units
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get units;

  /// Currency field label
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// Purchase price field label
  ///
  /// In en, this message translates to:
  /// **'Purchase Price'**
  String get purchasePrice;

  /// Mortgage field label
  ///
  /// In en, this message translates to:
  /// **'Mortgage'**
  String get mortgage;

  /// Notes field label
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// Empty properties message
  ///
  /// In en, this message translates to:
  /// **'No properties yet'**
  String get noProperties;

  /// Empty properties subtitle
  ///
  /// In en, this message translates to:
  /// **'Add your first property to get started'**
  String get addYourFirstProperty;

  /// Property details title
  ///
  /// In en, this message translates to:
  /// **'Property Details'**
  String get propertyDetails;

  /// Number of units label
  ///
  /// In en, this message translates to:
  /// **'Number of Units'**
  String get numberOfUnits;

  /// Property type: multi-story building
  ///
  /// In en, this message translates to:
  /// **'Immeuble'**
  String get typeImmeuble;

  /// Property type: compound
  ///
  /// In en, this message translates to:
  /// **'Compound'**
  String get typeCompound;

  /// Property type: house
  ///
  /// In en, this message translates to:
  /// **'Maison'**
  String get typeMaison;

  /// Property type: studio
  ///
  /// In en, this message translates to:
  /// **'Studio'**
  String get typeStudio;

  /// Property type: duplex
  ///
  /// In en, this message translates to:
  /// **'Duplex'**
  String get typeDuplex;

  /// Property type: villa
  ///
  /// In en, this message translates to:
  /// **'Villa'**
  String get typeVilla;

  /// Property type: commercial
  ///
  /// In en, this message translates to:
  /// **'Commercial'**
  String get typeCommercial;

  /// Property type: land/terrain
  ///
  /// In en, this message translates to:
  /// **'Terrain'**
  String get typeTerrain;

  /// Property type: other
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get typeOther;

  /// Single unit
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// Add unit button
  ///
  /// In en, this message translates to:
  /// **'Add Unit'**
  String get addUnit;

  /// Edit unit button
  ///
  /// In en, this message translates to:
  /// **'Edit Unit'**
  String get editUnit;

  /// Delete unit button
  ///
  /// In en, this message translates to:
  /// **'Delete Unit'**
  String get deleteUnit;

  /// Unit label field
  ///
  /// In en, this message translates to:
  /// **'Unit Label'**
  String get unitLabel;

  /// Floor number field
  ///
  /// In en, this message translates to:
  /// **'Floor Number'**
  String get floorNumber;

  /// Unit type field
  ///
  /// In en, this message translates to:
  /// **'Unit Type'**
  String get unitType;

  /// Number of bedrooms
  ///
  /// In en, this message translates to:
  /// **'Bedrooms'**
  String get bedrooms;

  /// Number of bathrooms
  ///
  /// In en, this message translates to:
  /// **'Bathrooms'**
  String get bathrooms;

  /// Size field
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// Rent amount field
  ///
  /// In en, this message translates to:
  /// **'Rent Amount'**
  String get rentAmount;

  /// Unit occupied status
  ///
  /// In en, this message translates to:
  /// **'Occupied'**
  String get occupied;

  /// Unit vacant status
  ///
  /// In en, this message translates to:
  /// **'Vacant'**
  String get vacant;

  /// Empty units message
  ///
  /// In en, this message translates to:
  /// **'No units yet'**
  String get noUnits;

  /// Empty units subtitle
  ///
  /// In en, this message translates to:
  /// **'Add your first unit to this property'**
  String get addYourFirstUnit;

  /// Unit details title
  ///
  /// In en, this message translates to:
  /// **'Unit Details'**
  String get unitDetails;

  /// Unit type: apartment
  ///
  /// In en, this message translates to:
  /// **'Appartement'**
  String get unitTypeAppartement;

  /// Unit type: room
  ///
  /// In en, this message translates to:
  /// **'Chambre'**
  String get unitTypeChambre;

  /// Unit type: studio
  ///
  /// In en, this message translates to:
  /// **'Studio'**
  String get unitTypeStudio;

  /// Unit type: shop
  ///
  /// In en, this message translates to:
  /// **'Boutique'**
  String get unitTypeBoutique;

  /// Unit type: office
  ///
  /// In en, this message translates to:
  /// **'Bureau'**
  String get unitTypeBureau;

  /// Unit type: store
  ///
  /// In en, this message translates to:
  /// **'Magasin'**
  String get unitTypeMagasin;

  /// Unit type: garage
  ///
  /// In en, this message translates to:
  /// **'Garage'**
  String get unitTypeGarage;

  /// Unit type: other
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get unitTypeOther;

  /// Single tenant
  ///
  /// In en, this message translates to:
  /// **'Tenant'**
  String get tenant;

  /// Multiple tenants
  ///
  /// In en, this message translates to:
  /// **'Tenants'**
  String get tenants;

  /// Add tenant button
  ///
  /// In en, this message translates to:
  /// **'Add Tenant'**
  String get addTenant;

  /// Edit tenant button
  ///
  /// In en, this message translates to:
  /// **'Edit Tenant'**
  String get editTenant;

  /// Delete tenant button
  ///
  /// In en, this message translates to:
  /// **'Delete Tenant'**
  String get deleteTenant;

  /// Phone field label
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// ID number field label
  ///
  /// In en, this message translates to:
  /// **'ID Number'**
  String get idNumber;

  /// Lease start date field
  ///
  /// In en, this message translates to:
  /// **'Lease Start'**
  String get leaseStart;

  /// Lease end date field
  ///
  /// In en, this message translates to:
  /// **'Lease End'**
  String get leaseEnd;

  /// Deposit field label
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get deposit;

  /// Payment frequency field
  ///
  /// In en, this message translates to:
  /// **'Payment Frequency'**
  String get paymentFrequency;

  /// Empty tenants message
  ///
  /// In en, this message translates to:
  /// **'No tenants yet'**
  String get noTenants;

  /// Empty tenants subtitle
  ///
  /// In en, this message translates to:
  /// **'Add your first tenant to get started'**
  String get addYourFirstTenant;

  /// Tenant details title
  ///
  /// In en, this message translates to:
  /// **'Tenant Details'**
  String get tenantDetails;

  /// Lease information section title
  ///
  /// In en, this message translates to:
  /// **'Lease Information'**
  String get leaseInformation;

  /// Contact information section title
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// Assigned unit label
  ///
  /// In en, this message translates to:
  /// **'Assigned Unit'**
  String get assignedUnit;

  /// No unit assigned message
  ///
  /// In en, this message translates to:
  /// **'No unit assigned'**
  String get noUnit;

  /// Payment frequency: monthly
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get frequencyMonthly;

  /// Payment frequency: quarterly
  ///
  /// In en, this message translates to:
  /// **'Quarterly'**
  String get frequencyQuarterly;

  /// Payment frequency: biannual
  ///
  /// In en, this message translates to:
  /// **'Biannual'**
  String get frequencyBiannual;

  /// Payment frequency: annual
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get frequencyAnnual;

  /// Income label
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// Expense label
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// Add transaction button
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransaction;

  /// Edit transaction button
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get editTransaction;

  /// Delete transaction button
  ///
  /// In en, this message translates to:
  /// **'Delete Transaction'**
  String get deleteTransaction;

  /// Amount field label
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// Category field label
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Date field label
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Description field label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Total income label
  ///
  /// In en, this message translates to:
  /// **'Total Income'**
  String get totalIncome;

  /// Total expenses label
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get totalExpenses;

  /// Net profit label
  ///
  /// In en, this message translates to:
  /// **'Net Profit'**
  String get netProfit;

  /// Profit margin label
  ///
  /// In en, this message translates to:
  /// **'Profit Margin'**
  String get profitMargin;

  /// Transaction type label
  ///
  /// In en, this message translates to:
  /// **'Transaction Type'**
  String get transactionType;

  /// Empty transactions message
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactions;

  /// Empty transactions subtitle
  ///
  /// In en, this message translates to:
  /// **'Add your first transaction to track finances'**
  String get addYourFirstTransaction;

  /// Rent category
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get rent;

  /// Utilities category
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get utilities;

  /// Repairs category
  ///
  /// In en, this message translates to:
  /// **'Repairs'**
  String get repairs;

  /// Insurance category
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get insurance;

  /// Taxes category
  ///
  /// In en, this message translates to:
  /// **'Taxes'**
  String get taxes;

  /// Other category
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// Maintenance label
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get maintenance;

  /// Add maintenance request button
  ///
  /// In en, this message translates to:
  /// **'Add Request'**
  String get addRequest;

  /// Edit maintenance request button
  ///
  /// In en, this message translates to:
  /// **'Edit Request'**
  String get editRequest;

  /// Title field label
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// Priority field label
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// Status field label
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// Cost field label
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get cost;

  /// Maintenance status: open
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get statusOpen;

  /// Maintenance status: in progress
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get statusInProgress;

  /// Maintenance status: resolved
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get statusResolved;

  /// Priority: low
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// Priority: medium
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get priorityMedium;

  /// Priority: high
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// Priority: urgent
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get priorityUrgent;

  /// Start work button
  ///
  /// In en, this message translates to:
  /// **'Start Work'**
  String get startWork;

  /// Mark resolved button
  ///
  /// In en, this message translates to:
  /// **'Mark Resolved'**
  String get markResolved;

  /// Empty maintenance message
  ///
  /// In en, this message translates to:
  /// **'No maintenance requests'**
  String get noMaintenanceRequests;

  /// Maintenance details title
  ///
  /// In en, this message translates to:
  /// **'Maintenance Details'**
  String get maintenanceDetails;

  /// Request date label
  ///
  /// In en, this message translates to:
  /// **'Request Date'**
  String get requestDate;

  /// Resolved date label
  ///
  /// In en, this message translates to:
  /// **'Resolved Date'**
  String get resolvedDate;

  /// AI assistant title
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiAssistant;

  /// Price predictor title
  ///
  /// In en, this message translates to:
  /// **'Price Predictor'**
  String get pricePredictor;

  /// Profitability analysis title
  ///
  /// In en, this message translates to:
  /// **'Profitability Analysis'**
  String get profitabilityAnalysis;

  /// Predict button
  ///
  /// In en, this message translates to:
  /// **'Predict'**
  String get predict;

  /// Analyze button
  ///
  /// In en, this message translates to:
  /// **'Analyze'**
  String get analyze;

  /// AI input placeholder
  ///
  /// In en, this message translates to:
  /// **'Ask AI...'**
  String get askAI;

  /// AI suggestions section title
  ///
  /// In en, this message translates to:
  /// **'AI Suggestions'**
  String get aiSuggestions;

  /// Estimated price label
  ///
  /// In en, this message translates to:
  /// **'Estimated Price'**
  String get estimatedPrice;

  /// Profitability score label
  ///
  /// In en, this message translates to:
  /// **'Profitability Score'**
  String get profitabilityScore;

  /// Market analysis label
  ///
  /// In en, this message translates to:
  /// **'Market Analysis'**
  String get marketAnalysis;

  /// Recommendation label
  ///
  /// In en, this message translates to:
  /// **'Recommendation'**
  String get recommendation;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Loading indicator text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Error title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No data message
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// Back button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Continue button
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Search label
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Filter label
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// All filter option
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// View all link
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// Confirm button
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get areYouSure;

  /// Yes option
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No option
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// OK button
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Edit button
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Add button
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Remove button
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// Update button
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// Submit button
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// Select label
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// Required field indicator
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// Optional field indicator
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// Success message
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Warning message
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// Info message
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// Try again prompt
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// Empty search results message
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// Actions menu label
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// Dashboard greeting
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// Dashboard greeting with user name
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String helloUser(String name);

  /// Financial overview section title
  ///
  /// In en, this message translates to:
  /// **'Financial Overview'**
  String get financialOverview;

  /// Recent payments section title
  ///
  /// In en, this message translates to:
  /// **'Recent Payments'**
  String get recentPayments;

  /// Quick actions section title
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// Occupancy label
  ///
  /// In en, this message translates to:
  /// **'Occupancy'**
  String get occupancy;

  /// Occupancy rate label
  ///
  /// In en, this message translates to:
  /// **'Occupancy Rate'**
  String get occupancyRate;

  /// Total properties stat
  ///
  /// In en, this message translates to:
  /// **'Total Properties'**
  String get totalProperties;

  /// Total units stat
  ///
  /// In en, this message translates to:
  /// **'Total Units'**
  String get totalUnits;

  /// Total tenants stat
  ///
  /// In en, this message translates to:
  /// **'Total Tenants'**
  String get totalTenants;

  /// Monthly income stat
  ///
  /// In en, this message translates to:
  /// **'Monthly Income'**
  String get monthlyIncome;

  /// Pending maintenance stat
  ///
  /// In en, this message translates to:
  /// **'Pending Maintenance'**
  String get pendingMaintenance;

  /// Overview section label
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// French language option
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// Settings label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Theme setting label
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Dark mode setting
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Light mode setting
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// System default setting
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// Notifications setting
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// About section
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Privacy policy link
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Terms of service link
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// Number of units
  ///
  /// In en, this message translates to:
  /// **'{count} units'**
  String nUnits(int count);

  /// Number of tenants
  ///
  /// In en, this message translates to:
  /// **'{count} tenants'**
  String nTenants(int count);

  /// Number of properties
  ///
  /// In en, this message translates to:
  /// **'{count} properties'**
  String nProperties(int count);

  /// Delete confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this?'**
  String get deleteConfirmation;

  /// Irreversible action warning
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get cannotBeUndone;

  /// Save success message
  ///
  /// In en, this message translates to:
  /// **'Saved successfully'**
  String get savedSuccessfully;

  /// Delete success message
  ///
  /// In en, this message translates to:
  /// **'Deleted successfully'**
  String get deletedSuccessfully;

  /// Update success message
  ///
  /// In en, this message translates to:
  /// **'Updated successfully'**
  String get updatedSuccessfully;

  /// Create success message
  ///
  /// In en, this message translates to:
  /// **'Created successfully'**
  String get createdSuccessfully;

  /// Per month suffix
  ///
  /// In en, this message translates to:
  /// **'/month'**
  String get perMonth;

  /// Square meters unit
  ///
  /// In en, this message translates to:
  /// **'m²'**
  String get squareMeters;

  /// Date picker prompt
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// Property selection prompt
  ///
  /// In en, this message translates to:
  /// **'Select Property'**
  String get selectProperty;

  /// Unit selection prompt
  ///
  /// In en, this message translates to:
  /// **'Select Unit'**
  String get selectUnit;

  /// Tenant selection prompt
  ///
  /// In en, this message translates to:
  /// **'Select Tenant'**
  String get selectTenant;

  /// From date label
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// To date label
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// Total label
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// Average label
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// Monthly period label
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// Yearly period label
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// Today label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// This month label
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// This year label
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get thisYear;

  /// Last month label
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get lastMonth;

  /// Last year label
  ///
  /// In en, this message translates to:
  /// **'Last Year'**
  String get lastYear;

  /// Custom period label
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
