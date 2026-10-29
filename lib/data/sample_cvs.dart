import 'package:flutter/material.dart';
import '../models/cv_model.dart';

class SampleCvDefinition {
  final String roleId;
  final String roleName;
  final String description;
  final IconData icon;
  final CvModel Function() createSampleCv;

  SampleCvDefinition({
    required this.roleId,
    required this.roleName,
    required this.description,
    required this.icon,
    required this.createSampleCv,
  });
}

class SampleCvsData {
  static List<SampleCvDefinition> getAllSamples() {
    return [
      // 1. Teacher
      SampleCvDefinition(
        roleId: 'teacher',
        roleName: 'Teacher',
        description: 'Primary/Secondary school educator with lesson planning & exam assessment',
        icon: Icons.school_outlined,
        createSampleCv: () => CvModel(
          title: 'Teacher CV',
          template: 'classic',
          photoPath: null,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          // Personal details are strictly BLANK per locked requirement
          personal: PersonalDetails(
            fullName: '',
            phone: '',
            email: '',
            city: '',
            address: '',
            photoEnabled: false,
          ),
          objective:
              'Dedicated and student-focused Educator with strong subject competence in Mathematics, General Science, and English. Proven track record in fostering engaging classroom environments, interactive teaching methodologies, and holistic student academic improvement in Pakistani private and public schools.',
          education: [
            EducationItem(
              degree: 'B.Ed (1.5 Years) Secondary Education',
              institution: 'University of Education, Lahore',
              city: 'Lahore',
              passingYear: '2022',
              marksOrGrade: '1st Division (3.5 CGPA)',
              orderIndex: 0,
            ),
            EducationItem(
              degree: 'B.Sc (Double Math & Physics)',
              institution: 'University of the Punjab',
              city: 'Lahore',
              passingYear: '2020',
              marksOrGrade: '1st Division',
              orderIndex: 1,
            ),
          ],
          experience: [
            ExperienceItem(
              jobTitle: 'Senior Science Teacher',
              company: 'The Educators School System',
              city: 'Lahore',
              startDate: 'Aug 2022',
              endDate: 'Present',
              isCurrent: true,
              description:
                  'Taught Science and Mathematics to grades 7-9. Prepared comprehensive weekly lesson plans and multimedia aids. Organised annual science exhibitions and supervised parent-teacher evaluation meetings for 120+ students.',
              orderIndex: 0,
            ),
            ExperienceItem(
              jobTitle: 'Assistant Teacher',
              company: 'City Grammar High School',
              city: 'Lahore',
              startDate: 'Sep 2020',
              endDate: 'Jul 2022',
              isCurrent: false,
              description:
                  'Assisted senior faculty with class instruction, test preparation, paper marking, and extracurricular speech competitions.',
              orderIndex: 1,
            ),
          ],
          skills: [
            SkillItem(skillName: 'Classroom Management', level: 'Expert', orderIndex: 0),
            SkillItem(skillName: 'Lesson Planning & Pedagogy', level: 'Expert', orderIndex: 1),
            SkillItem(skillName: 'Student Counseling', level: 'Advanced', orderIndex: 2),
            SkillItem(skillName: 'Curriculum Assessment', level: 'Advanced', orderIndex: 3),
            SkillItem(skillName: 'Urdu & English Communication', level: 'Fluent', orderIndex: 4),
          ],
          languages: [
            LanguageItem(languageName: 'Urdu', proficiency: 'Native', orderIndex: 0),
            LanguageItem(languageName: 'English', proficiency: 'Professional Working', orderIndex: 1),
            LanguageItem(languageName: 'Punjabi', proficiency: 'Conversational', orderIndex: 2),
          ],
          certifications: [
            CertificationItem(
              title: 'Modern Pedagogy & Active Learning Workshop',
              institute: 'British Council Pakistan',
              year: '2023',
              orderIndex: 0,
            ),
          ],
          references: [
            ReferenceItem(
              name: 'Available upon request',
              designation: 'Academic & Professional References',
              contact: 'Contact will be provided on demand',
              orderIndex: 0,
            ),
          ],
          hobbies: [
            HobbyItem(name: 'Educational Blogging & Journal Reading', orderIndex: 0),
            HobbyItem(name: 'Debating Society Mentorship', orderIndex: 1),
          ],
        ),
      ),

      // 2. Nurse
      SampleCvDefinition(
        roleId: 'nurse',
        roleName: 'Nurse',
        description: 'PNC registered hospital staff nurse for ICU, emergency & clinical care',
        icon: Icons.medical_services_outlined,
        createSampleCv: () => CvModel(
          title: 'Staff Nurse CV',
          template: 'classic',
          photoPath: null,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          personal: PersonalDetails(
            fullName: '',
            phone: '',
            email: '',
            city: '',
            address: '',
            photoEnabled: false,
          ),
          objective:
              'Empathetic and licensed Staff Nurse with comprehensive clinical experience in intensive care units, emergency triage, and surgical wards. Committed to delivering patient-centred nursing care with strict compliance to aseptic medical protocols and hospital safety standards.',
          education: [
            EducationItem(
              degree: 'B.Sc Nursing (Generic 4-Year)',
              institution: 'Dow University of Health Sciences (DUHS)',
              city: 'Karachi',
              passingYear: '2021',
              marksOrGrade: 'PNC Registered (Grade A)',
              orderIndex: 0,
            ),
            EducationItem(
              degree: 'Diploma in General Nursing',
              institution: 'Sindh Nursing Examination Board',
              city: 'Karachi',
              passingYear: '2019',
              marksOrGrade: '1st Division',
              orderIndex: 1,
            ),
          ],
          experience: [
            ExperienceItem(
              jobTitle: 'Staff Nurse (ICU Ward)',
              company: 'Civil Hospital / Dr. Ruth K. Pfau Hospital',
              city: 'Karachi',
              startDate: 'Jan 2022',
              endDate: 'Present',
              isCurrent: true,
              description:
                  'Monitoring critical patient vital signs, operating arterial lines and mechanical ventilators. Administering controlled intravenous infusions, maintaining patient electronic medical records, and collaborating with attending consultants during emergencies.',
              orderIndex: 0,
            ),
            ExperienceItem(
              jobTitle: 'Clinical Ward Nurse',
              company: 'Liaquat National Hospital',
              city: 'Karachi',
              startDate: 'Jul 2021',
              endDate: 'Dec 2021',
              isCurrent: false,
              description:
                  'Delivered pre-operative and post-operative nursing care in general surgical ward. Managed medication charts and patient hygiene protocols.',
              orderIndex: 1,
            ),
          ],
          skills: [
            SkillItem(skillName: 'Patient Triage & Vital Monitoring', level: 'Expert', orderIndex: 0),
            SkillItem(skillName: 'IV Cannulation & Medication Administration', level: 'Expert', orderIndex: 1),
            SkillItem(skillName: 'Infection Control & Sterile Techniques', level: 'Advanced', orderIndex: 2),
            SkillItem(skillName: 'Basic Life Support (BLS)', level: 'Certified', orderIndex: 3),
            SkillItem(skillName: 'Electronic Health Records (EHR)', level: 'Proficient', orderIndex: 4),
          ],
          languages: [
            LanguageItem(languageName: 'Urdu', proficiency: 'Fluent', orderIndex: 0),
            LanguageItem(languageName: 'English', proficiency: 'Professional Working', orderIndex: 1),
            LanguageItem(languageName: 'Sindhi', proficiency: 'Conversational', orderIndex: 2),
          ],
          certifications: [
            CertificationItem(
              title: 'BLS (Basic Life Support) Provider',
              institute: 'American Heart Association / DUHS',
              year: '2023',
              orderIndex: 0,
            ),
            CertificationItem(
              title: 'Active PNC Nursing Registration',
              institute: 'Pakistan Nursing Council (PNC)',
              year: 'Valid till 2027',
              orderIndex: 1,
            ),
          ],
          references: [
            ReferenceItem(
              name: 'Available upon request',
              designation: 'Clinical Nursing Supervisors',
              contact: 'Provided upon institutional inquiry',
              orderIndex: 0,
            ),
          ],
          hobbies: [
            HobbyItem(name: 'Community First Aid Awareness Camps', orderIndex: 0),
            HobbyItem(name: 'Public Health Seminars', orderIndex: 1),
          ],
        ),
      ),

      // 3. Bank Clerk
      SampleCvDefinition(
        roleId: 'bank_clerk',
        roleName: 'Bank Clerk',
        description: 'Branch cashier & customer service representative with cash counter & KYC expertise',
        icon: Icons.account_balance_outlined,
        createSampleCv: () => CvModel(
          title: 'Bank Clerk CV',
          template: 'classic',
          photoPath: null,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          personal: PersonalDetails(
            fullName: '',
            phone: '',
            email: '',
            city: '',
            address: '',
            photoEnabled: false,
          ),
          objective:
              'Diligent and trustworthy Banking Professional with in-depth knowledge of branch counter cash operations, account opening KYC/AML compliance, clearing cheques, and core banking software. Seeking a Branch Officer / Cash Officer role in a commercial banking institution.',
          education: [
            EducationItem(
              degree: 'BBA (Hons) Banking & Finance',
              institution: 'Institute of Business Administration (IBA) / UoK',
              city: 'Karachi',
              passingYear: '2022',
              marksOrGrade: 'CGPA 3.3',
              orderIndex: 0,
            ),
            EducationItem(
              degree: 'HSSC (Commerce / I.Com)',
              institution: 'Govt Premier College of Commerce',
              city: 'Karachi',
              passingYear: '2018',
              marksOrGrade: 'Grade A',
              orderIndex: 1,
            ),
          ],
          experience: [
            ExperienceItem(
              jobTitle: 'Cash Officer / Teller',
              company: 'Habib Bank Limited (HBL)',
              city: 'Rawalpindi',
              startDate: 'Jan 2023',
              endDate: 'Present',
              isCurrent: true,
              description:
                  'Managed daily branch cash deposits, withdrawals, and utility bill collections exceeding PKR 6M daily with zero cash shortages. Processed pay orders, demand drafts, and executed inter-branch clearing transactions.',
              orderIndex: 0,
            ),
            ExperienceItem(
              jobTitle: 'Customer Services Officer',
              company: 'United Bank Limited (UBL)',
              city: 'Islamabad',
              startDate: 'Jun 2022',
              endDate: 'Dec 2022',
              isCurrent: false,
              description:
                  'Handled new digital and biometric account opening forms adhering strictly to SBP guidelines. Assisted account holders with cheque books, ATM cards, and mobile banking activation.',
              orderIndex: 1,
            ),
          ],
          skills: [
            SkillItem(skillName: 'Cash Counter Handling & Sorting', level: 'Expert', orderIndex: 0),
            SkillItem(skillName: 'KYC & Anti-Money Laundering (AML)', level: 'Advanced', orderIndex: 1),
            SkillItem(skillName: 'Core Banking Software (Temenos/T24)', level: 'Advanced', orderIndex: 2),
            SkillItem(skillName: 'Cheque Clearing & Pay Orders', level: 'Advanced', orderIndex: 3),
            SkillItem(skillName: 'MS Excel & Daily Reconciliation', level: 'Proficient', orderIndex: 4),
          ],
          languages: [
            LanguageItem(languageName: 'Urdu', proficiency: 'Native', orderIndex: 0),
            LanguageItem(languageName: 'English', proficiency: 'Professional Working', orderIndex: 1),
            LanguageItem(languageName: 'Potohari / Punjabi', proficiency: 'Conversational', orderIndex: 2),
          ],
          certifications: [
            CertificationItem(
              title: 'Certificate in Islamic Banking Operations',
              institute: 'Institute of Bankers Pakistan (IBP)',
              year: '2023',
              orderIndex: 0,
            ),
          ],
          references: [
            ReferenceItem(
              name: 'Available upon request',
              designation: 'Branch Managers & Operation Heads',
              contact: 'Available on request',
              orderIndex: 0,
            ),
          ],
          hobbies: [
            HobbyItem(name: 'Financial News & Stock Market Analysis', orderIndex: 0),
            HobbyItem(name: 'Table Tennis', orderIndex: 1),
          ],
        ),
      ),

      // 4. IT Graduate
      SampleCvDefinition(
        roleId: 'it_graduate',
        roleName: 'IT Graduate',
        description: 'Fresh software engineer / computer science graduate with mobile & web portfolio',
        icon: Icons.code_outlined,
        createSampleCv: () => CvModel(
          title: 'IT Graduate CV',
          template: 'classic',
          photoPath: null,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          personal: PersonalDetails(
            fullName: '',
            phone: '',
            email: '',
            city: '',
            address: '',
            photoEnabled: false,
          ),
          objective:
              'Enthusiastic and technically skilled Fresh Computer Science Graduate with strong hands-on proficiency in Flutter, Dart, Python, and relational databases. Seeking an Associate Software Engineer role in a forward-thinking software house to contribute to scalable cross-platform mobile and web applications.',
          education: [
            EducationItem(
              degree: 'BS Computer Science (BSCS)',
              institution: 'FAST-NUCES / NUST',
              city: 'Islamabad',
              passingYear: '2024',
              marksOrGrade: 'CGPA 3.45',
              orderIndex: 0,
            ),
            EducationItem(
              degree: 'F.Sc Pre-Engineering',
              institution: 'Punjab Group of Colleges',
              city: 'Lahore',
              passingYear: '2020',
              marksOrGrade: 'Grade A1 (88%)',
              orderIndex: 1,
            ),
          ],
          experience: [
            ExperienceItem(
              jobTitle: 'Software Engineering Intern',
              company: 'Systems Limited',
              city: 'Lahore',
              startDate: 'Jun 2023',
              endDate: 'Aug 2023',
              isCurrent: false,
              description:
                  'Assisted the mobile team in developing responsive Flutter UI screens, integrated REST APIs with proper state management, and resolved 25+ sprint bug tickets in an Agile Scrum environment.',
              orderIndex: 0,
            ),
          ],
          projects: [
            ProjectItem(
              title: 'Campus Food Ordering Mobile App',
              description:
                  'Cross-platform Flutter application featuring real-time menu synchronization, cart state management, and push notification alerts for campus dining halls.',
              linkOrTools: 'Flutter, Dart, SQLite, Provider',
              orderIndex: 0,
            ),
            ProjectItem(
              title: 'AI Crop Disease Detection System (FYP)',
              description:
                  'Mobile app that captures leaf pictures, runs an on-device TensorFlow Lite model, and suggests organic remediation measures to Pakistani farmers in Urdu.',
              linkOrTools: 'Flutter, Python, TensorFlow Lite, FastAPI',
              orderIndex: 1,
            ),
          ],
          skills: [
            SkillItem(skillName: 'Flutter & Dart', level: 'Advanced', orderIndex: 0),
            SkillItem(skillName: 'Python & OOP', level: 'Intermediate', orderIndex: 1),
            SkillItem(skillName: 'SQL, SQLite & Database Design', level: 'Intermediate', orderIndex: 2),
            SkillItem(skillName: 'Git & GitHub Collaboration', level: 'Proficient', orderIndex: 3),
            SkillItem(skillName: 'REST API Integration', level: 'Advanced', orderIndex: 4),
          ],
          languages: [
            LanguageItem(languageName: 'Urdu', proficiency: 'Native', orderIndex: 0),
            LanguageItem(languageName: 'English', proficiency: 'Fluent (IELTS 7.5 equivalent)', orderIndex: 1),
          ],
          certifications: [
            CertificationItem(
              title: 'Flutter & Dart Complete Guide Certificate',
              institute: 'Udemy / Google Developer Group',
              year: '2023',
              orderIndex: 0,
            ),
          ],
          references: [
            ReferenceItem(
              name: 'Available upon request',
              designation: 'Department of Computer Science Professors',
              contact: 'Will be furnished upon request',
              orderIndex: 0,
            ),
          ],
          hobbies: [
            HobbyItem(name: 'Open Source GitHub Contributions', orderIndex: 0),
            HobbyItem(name: 'Speed Chess & LeetCode Problem Solving', orderIndex: 1),
          ],
        ),
      ),

      // 5. Govt Job
      SampleCvDefinition(
        roleId: 'govt_job',
        roleName: 'Govt Job',
        description: 'Clerical, Junior Clerk / UDC format with official Urdu/English drafting skills',
        icon: Icons.account_balance_wallet_outlined,
        createSampleCv: () => CvModel(
          title: 'Govt Job Applicant CV',
          template: 'classic',
          photoPath: null,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          personal: PersonalDetails(
            fullName: '',
            phone: '',
            email: '',
            city: '',
            address: '',
            photoEnabled: false,
          ),
          objective:
              'Disciplined and detail-oriented candidate seeking a Junior Clerk (BS-11) or Upper Division Clerk (UDC) position in Federal/Provincial government departments. Possesses fast English and Urdu typing speeds, official dispatch filing knowledge, and exemplary office record keeping expertise.',
          education: [
            EducationItem(
              degree: 'B.A (General Arts)',
              institution: 'University of Peshawar',
              city: 'Peshawar',
              passingYear: '2021',
              marksOrGrade: '1st Division',
              orderIndex: 0,
            ),
            EducationItem(
              degree: 'Intermediate (F.A Civics & History)',
              institution: 'BISE Peshawar',
              city: 'Peshawar',
              passingYear: '2018',
              marksOrGrade: '1st Division',
              orderIndex: 1,
            ),
            EducationItem(
              degree: 'Matriculation (Science)',
              institution: 'Govt High School No. 1, Peshawar',
              city: 'Peshawar',
              passingYear: '2016',
              marksOrGrade: 'Grade A',
              orderIndex: 2,
            ),
          ],
          experience: [
            ExperienceItem(
              jobTitle: 'Data Entry Operator (Contractual)',
              company: 'Deputy Commissioner Office / District Administration',
              city: 'Peshawar',
              startDate: 'Mar 2022',
              endDate: 'Present',
              isCurrent: true,
              description:
                  'Maintaining citizen domicile and record registers, typing daily departmental summaries, managing official file diaries, and preparing routine meeting minutes for administrative officers.',
              orderIndex: 0,
            ),
            ExperienceItem(
              jobTitle: 'Office Assistant',
              company: 'Khyber Transport & Logistics Agency',
              city: 'Peshawar',
              startDate: 'Feb 2021',
              endDate: 'Feb 2022',
              isCurrent: false,
              description:
                  'Maintained vehicle dispatch ledgers, compiled monthly attendance reports, and managed official correspondence archival.',
              orderIndex: 1,
            ),
          ],
          skills: [
            SkillItem(skillName: 'English Typing Speed (45+ WPM)', level: 'Expert', orderIndex: 0),
            SkillItem(skillName: 'Urdu InPage Typing Speed (35+ WPM)', level: 'Advanced', orderIndex: 1),
            SkillItem(skillName: 'MS Office (Word, Excel, PowerPoint)', level: 'Proficient', orderIndex: 2),
            SkillItem(skillName: 'Official Note Sheet & Dispatch Drafting', level: 'Expert', orderIndex: 3),
            SkillItem(skillName: 'Secretarial File Management & Archiving', level: 'Advanced', orderIndex: 4),
          ],
          languages: [
            LanguageItem(languageName: 'Urdu', proficiency: 'Fluent', orderIndex: 0),
            LanguageItem(languageName: 'Pashto', proficiency: 'Native', orderIndex: 1),
            LanguageItem(languageName: 'English', proficiency: 'Working Knowledge', orderIndex: 2),
          ],
          certifications: [
            CertificationItem(
              title: 'Diploma in Information Technology (DIT 1-Year)',
              institute: 'Khyber Pakhtunkhwa Board of Technical Education',
              year: '2022',
              orderIndex: 0,
            ),
          ],
          references: [
            ReferenceItem(
              name: 'Available upon request',
              designation: 'Departmental Section Officers',
              contact: 'Will be furnished upon official call letter',
              orderIndex: 0,
            ),
          ],
          hobbies: [
            HobbyItem(name: 'National Dailies & Current Affairs Reading', orderIndex: 0),
            HobbyItem(name: 'Community Social Welfare Initiatives', orderIndex: 1),
          ],
        ),
      ),

      // 6. Shop / Sales
      SampleCvDefinition(
        roleId: 'shop_sales',
        roleName: 'Shop / Sales',
        description: 'Retail sales associate & showroom executive with counter billing & customer relations',
        icon: Icons.storefront_outlined,
        createSampleCv: () => CvModel(
          title: 'Shop Sales Executive CV',
          template: 'classic',
          photoPath: null,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          personal: PersonalDetails(
            fullName: '',
            phone: '',
            email: '',
            city: '',
            address: '',
            photoEnabled: false,
          ),
          objective:
              'Dynamic and customer-oriented Retail Sales Executive with 3+ years experience in garment and electronics showrooms in leading Pakistani shopping centres. Skilled in energetic greeting, persuasive product demonstrations, POS counter cashiering, and monthly sales quota achievement.',
          education: [
            EducationItem(
              degree: 'Intermediate (I.Com)',
              institution: 'Board of Intermediate Education Karachi (BIEK)',
              city: 'Karachi',
              passingYear: '2021',
              marksOrGrade: 'Grade B',
              orderIndex: 0,
            ),
            EducationItem(
              degree: 'Matriculation (Science)',
              institution: 'Board of Secondary Education Karachi',
              city: 'Karachi',
              passingYear: '2019',
              marksOrGrade: 'Grade A',
              orderIndex: 1,
            ),
          ],
          experience: [
            ExperienceItem(
              jobTitle: 'Senior Sales Associate',
              company: 'Outfitters / Alkaram Studio (LuckyOne Mall)',
              city: 'Karachi',
              startDate: 'Oct 2022',
              endDate: 'Present',
              isCurrent: true,
              description:
                  'Assisting 90+ walk-in customers daily, demonstrating apparel quality, managing barcode checkout registers, and consistently achieving 115% of monthly retail sales targets.',
              orderIndex: 0,
            ),
            ExperienceItem(
              jobTitle: 'Retail Counter Assistant',
              company: 'Chase Up Departmental Store',
              city: 'Karachi',
              startDate: 'Aug 2021',
              endDate: 'Sep 2022',
              isCurrent: false,
              description:
                  'Managed aisle merchandising displays, verified price tagging, handled cash drawer handovers, and maintained stock inventory shelves.',
              orderIndex: 1,
            ),
          ],
          skills: [
            SkillItem(skillName: 'Customer Greeting & Service', level: 'Expert', orderIndex: 0),
            SkillItem(skillName: 'POS Billing & Cash Drawer Reconciliation', level: 'Advanced', orderIndex: 1),
            SkillItem(skillName: 'Product Demonstration & Upselling', level: 'Advanced', orderIndex: 2),
            SkillItem(skillName: 'Stock Auditing & Inventory Restocking', level: 'Proficient', orderIndex: 3),
            SkillItem(skillName: 'Effective Verbal Communication', level: 'Fluent', orderIndex: 4),
          ],
          languages: [
            LanguageItem(languageName: 'Urdu', proficiency: 'Fluent', orderIndex: 0),
            LanguageItem(languageName: 'English', proficiency: 'Basic / Retail Conversational', orderIndex: 1),
            LanguageItem(languageName: 'Sindhi / Memoni', proficiency: 'Conversational', orderIndex: 2),
          ],
          certifications: [
            CertificationItem(
              title: 'Certificate in Retail Customer Relationship Management',
              institute: 'Vocational Training Institute Karachi',
              year: '2022',
              orderIndex: 0,
            ),
          ],
          references: [
            ReferenceItem(
              name: 'Available upon request',
              designation: 'Retail Showroom Managers',
              contact: 'Available on request',
              orderIndex: 0,
            ),
          ],
          hobbies: [
            HobbyItem(name: 'Cricket Club & Fitness', orderIndex: 0),
            HobbyItem(name: 'Photography & Digital Marketing Trends', orderIndex: 1),
          ],
        ),
      ),
    ];
  }
}
