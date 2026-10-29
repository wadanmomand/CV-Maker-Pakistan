enum AppLanguage { romanUrdu, english }

class AppStrings {
  final AppLanguage language;

  AppStrings(this.language);

  bool get isRomanUrdu => language == AppLanguage.romanUrdu;

  // App Title
  String get appName => 'CV Maker Pakistan';

  // Home Screen
  String get myCvs => isRomanUrdu ? 'Mere CVs' : 'My CVs';
  String get createNewCv => isRomanUrdu ? 'Naya CV Banayen' : 'Create New CV';
  String get sampleCvs => isRomanUrdu ? 'Sample CVs' : 'Sample CVs';
  String get emptyTitle => isRomanUrdu ? 'Abhi koi CV nahi hai' : 'No CVs Yet';
  String get emptySubtitle => isRomanUrdu
      ? 'Apna pehla professional CV abhi banayen ya sample chunein'
      : 'Create your first professional CV now or pick a sample';
  String get createFirstCv => isRomanUrdu ? 'Apna pehla CV banayen' : 'Create First CV';
  String get edit => isRomanUrdu ? 'Edit Karein' : 'Edit';
  String get viewPdf => isRomanUrdu ? 'PDF' : 'PDF';
  String get duplicate => isRomanUrdu ? 'Duplicate' : 'Duplicate';
  String get rename => isRomanUrdu ? 'Naam Badlein' : 'Rename';
  String get sharePdf => isRomanUrdu ? 'PDF Share Karein' : 'Share PDF';
  String get delete => isRomanUrdu ? 'Delete' : 'Delete';
  String get deleteCvConfirmTitle => isRomanUrdu ? 'CV Delete Karein?' : 'Delete CV?';
  String get deleteCvConfirmBody => isRomanUrdu
      ? 'Kya aap waqai yeh CV delete karna chahte hain? Yeh wapis nahi aayega.'
      : 'Are you sure you want to delete this CV? This action cannot be undone.';
  String get cancel => isRomanUrdu ? 'Radd Karein' : 'Cancel';
  String get renameCv => isRomanUrdu ? 'CV Ka Naam Badlein' : 'Rename CV';
  String get save => isRomanUrdu ? 'Save' : 'Save';
  String get saved => isRomanUrdu ? 'Saved' : 'Saved';
  String get lastUpdated => isRomanUrdu ? 'Aakhri update' : 'Last updated';
  String get testAdNotice => 'Ad · Google AdMob Test Banner';

  // Form Screen
  String get createCv => isRomanUrdu ? 'Create CV' : 'Create CV';
  String get editCv => isRomanUrdu ? 'Edit CV' : 'Edit CV';
  String get next => isRomanUrdu ? 'Aage (Next)' : 'Next';
  String get back => isRomanUrdu ? 'Peechay (Back)' : 'Back';
  String get preview => isRomanUrdu ? 'Preview' : 'Preview';
  String get stepOf => isRomanUrdu ? 'Step' : 'Step';
  String get stepOutOf => isRomanUrdu ? 'of 10' : 'of 10';

  // Steps
  String get stepPersonal => isRomanUrdu ? 'Zaati Maloomat' : 'Personal';
  String get stepObjective => isRomanUrdu ? 'Maqsad (Objective)' : 'Objective';
  String get stepEducation => isRomanUrdu ? 'Taleem (Education)' : 'Education';
  String get stepExperience => isRomanUrdu ? 'Tajurba (Experience)' : 'Experience';
  String get stepSkills => isRomanUrdu ? 'Hunar (Skills)' : 'Skills';
  String get stepLanguages => isRomanUrdu ? 'Zubanein (Languages)' : 'Languages';
  String get stepProjects => isRomanUrdu ? 'Projects' : 'Projects';
  String get stepCertifications => isRomanUrdu ? 'Certifications' : 'Certifications';
  String get stepReferences => isRomanUrdu ? 'References' : 'References';
  String get stepHobbies => isRomanUrdu ? 'Mashghale (Hobbies)' : 'Hobbies';

  // Form Fields - Personal
  String get addPhoto => isRomanUrdu ? 'Photo shamil karein — optional' : 'Add Photo — optional';
  String get changePhoto => isRomanUrdu ? 'Photo tabdeel karein' : 'Change Photo';
  String get removePhoto => isRomanUrdu ? 'Photo hatayein' : 'Remove Photo';
  String get fullName => isRomanUrdu ? 'Pura Naam (Full Name) *' : 'Full Name *';
  String get fullNameHint => 'Ahmed Khan';
  String get fullNameError => isRomanUrdu ? 'Pura naam likhna zaroori hai' : 'Full Name is required';
  String get phoneNumber => isRomanUrdu ? 'Phone Number *' : 'Phone Number *';
  String get phoneNumberHint => '0300-1234567';
  String get phoneError => isRomanUrdu ? 'Phone number likhna zaroori hai' : 'Phone Number is required';
  String get email => isRomanUrdu ? 'Email Address (optional)' : 'Email (optional)';
  String get emailHint => 'ahmed.khan@example.com';
  String get city => isRomanUrdu ? 'Shehar (City) *' : 'City *';
  String get cityHint => 'Karachi, Lahore, Peshawar...';
  String get address => isRomanUrdu ? 'Pata / Address (optional, short)' : 'Address (optional, short)';
  String get addressHint => 'Model Town, Lahore';

  // Form - Objective
  String get objectiveTitle => isRomanUrdu ? 'Career Maqsad (Objective)' : 'Career Objective';
  String get objectiveHint => isRomanUrdu
      ? 'Apne career ka maqsad aur khulasa likhein...'
      : 'Write your career objective and summary...';

  // Common Form Actions
  String get addItem => isRomanUrdu ? '+ Naya Shamil Karein' : '+ Add Item';
  String get removeItem => isRomanUrdu ? 'Hatayein' : 'Remove';

  // Template Pick
  String get chooseTemplate => isRomanUrdu ? 'Template Chunein' : 'Choose Template';
  String get chooseTemplateSubtitle => isRomanUrdu
      ? 'Apne CV ke liye behtareen template muntakhib karein'
      : 'Pick a resume template to get started';
  String get useTemplate => isRomanUrdu ? 'Use Template' : 'Use Template';
  String get templateClassic => 'Classic ATS';
  String get templateClassicSub => 'Single column';
  String get templateModern => 'Modern';
  String get templateModernSub => 'Two columns with sidebar';
  String get templateMinimal => 'Minimal';
  String get templateMinimalSub => 'Clean & simple lines';
  String get templatePhoto => 'Photo CV';
  String get templatePhotoSub => 'Includes photo';

  // Preview Screen
  String get previewTitle => isRomanUrdu ? 'Live Preview' : 'Preview';
  String get editButton => isRomanUrdu ? 'Edit' : 'Edit';
  String get templateButton => isRomanUrdu ? 'Template' : 'Template';
  String get shareButton => isRomanUrdu ? 'Share' : 'Share';
  String get downloadPdfButton => isRomanUrdu ? 'Download PDF' : 'Download PDF';
  String get pageExceedWarning => isRomanUrdu
      ? 'CV 2 pages se zyada hai — kuch sections chota karein'
      : 'CV exceeds 2 pages — consider shortening some sections';
  String get pdfDownloadedToast => isRomanUrdu
      ? 'PDF download ho gayi hai: '
      : 'PDF saved to Downloads: ';

  // Samples Screen
  String get sampleCvsTitle => isRomanUrdu ? 'Sample CVs' : 'Sample CVs';
  String get useSampleButton => isRomanUrdu ? 'Use Sample' : 'Use Sample';
  String get sampleNotice => isRomanUrdu
      ? 'Sample CV chun kar apni zaati details bharein'
      : 'Select a sample CV and fill in your personal details';

  // Settings Screen
  String get settingsTitle => isRomanUrdu ? 'Settings / Privacy' : 'Settings / Privacy';
  String get languageSection => isRomanUrdu ? 'Zuban (Language)' : 'Language';
  String get romanUrduOption => 'Roman Urdu (Default)';
  String get englishOption => 'English';
  String get themeSection => isRomanUrdu ? 'Theme' : 'Theme';
  String get lightTheme => isRomanUrdu ? 'Light (Default)' : 'Light (Default)';
  String get darkTheme => isRomanUrdu ? 'Dark' : 'Dark';
  String get backupSection => isRomanUrdu ? 'Backup & Restore' : 'Backup & Restore';
  String get exportJson => isRomanUrdu ? 'Export JSON (local file)' : 'Export JSON (local file)';
  String get exportJsonSub => isRomanUrdu
      ? 'Apna saara data file mein save karein aur share karein'
      : 'Save all your CVs into a local JSON backup file';
  String get importJson => isRomanUrdu ? 'Import JSON (local file)' : 'Import JSON (local file)';
  String get importJsonSub => isRomanUrdu
      ? 'Pehlay se save ki gayi JSON file restore karein'
      : 'Restore CVs from a previously exported JSON backup';
  String get privacyPolicy => isRomanUrdu ? 'Privacy Policy' : 'Privacy Policy';
  String get privacyPolicySub => isRomanUrdu
      ? 'Offline aur mehfooz — aapka data phone par rehta hai'
      : 'Offline & secure — your data stays on your device';
  String get aboutSection => isRomanUrdu ? 'App Ke Baare Mein (About)' : 'About';
  String get appVersion => 'Version 1.0.0 (v1.0.0+1)';
  String get developerName => 'Developer: Aatish Studio';
  String get deleteAllData => isRomanUrdu ? 'Delete All Data' : 'Delete All Data';
  String get deleteAllDataSub => isRomanUrdu
      ? 'Saare CVs aur local photos hamesha ke liye mita dein'
      : 'Permanently wipe all CVs and local photos';

  // Delete All Confirm
  String get deleteAllFirstDialogTitle => isRomanUrdu ? 'Saara data delete ho jayega?' : 'Delete All Data?';
  String get deleteAllFirstDialogBody => isRomanUrdu
      ? 'Aapke saare CVs aur photos phone se delete ho jayenge. Ye amal wapis nahi ho sakta.'
      : 'All your CVs and photos will be deleted from this device. This action cannot be undone.';
  String get deleteAllSecondDialogTitle => isRomanUrdu ? 'Aakhri Tasdeeq' : 'Final Confirmation';
  String get deleteAllSecondDialogBody => isRomanUrdu
      ? 'Tasdeeq ke liye neeche DELETE likhein:'
      : 'Type DELETE below to confirm:';
  String get deleteConfirmWord => 'DELETE';
  String get dataDeletedToast => isRomanUrdu ? 'Saara data delete ho gaya' : 'All data wiped successfully';

  // Import Dialog
  String get importDialogTitle => isRomanUrdu ? 'Data Restore Karein' : 'Restore Backup';
  String get importDialogBody => isRomanUrdu
      ? 'Aap naye CVs shamil karna chahte hain (Merge) ya mojooda data badalna chahte hain (Replace all)?'
      : 'Do you want to merge imported CVs as new, or replace all existing CVs?';
  String get mergeOption => isRomanUrdu ? 'Merge (Naye shamil karein)' : 'Merge (Add as new)';
  String get replaceOption => isRomanUrdu ? 'Replace All (Sab badal dein)' : 'Replace All';
  String get invalidJsonError => isRomanUrdu
      ? 'Ghalat backup file! Koi tabdeeli nahi ki gayi.'
      : 'Invalid backup file format! No changes made.';
  String get importSuccess => isRomanUrdu ? 'Data kamyabi se restore ho gaya' : 'Backup imported successfully';
}
