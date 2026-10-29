class PersonalDetails {
  String fullName;
  String phone;
  String email;
  String city;
  String address;
  bool photoEnabled;

  PersonalDetails({
    this.fullName = '',
    this.phone = '',
    this.email = '',
    this.city = '',
    this.address = '',
    this.photoEnabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'city': city,
      'address': address,
      'photo_enabled': photoEnabled ? 1 : 0,
    };
  }

  factory PersonalDetails.fromMap(Map<String, dynamic> map) {
    return PersonalDetails(
      fullName: map['full_name'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
      city: map['city'] as String? ?? '',
      address: map['address'] as String? ?? '',
      photoEnabled: (map['photo_enabled'] as int? ?? 1) == 1,
    );
  }

  PersonalDetails copyWith({
    String? fullName,
    String? phone,
    String? email,
    String? city,
    String? address,
    bool? photoEnabled,
  }) {
    return PersonalDetails(
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      city: city ?? this.city,
      address: address ?? this.address,
      photoEnabled: photoEnabled ?? this.photoEnabled,
    );
  }
}

class EducationItem {
  int? id;
  int? cvId;
  String degree;
  String institution;
  String city;
  String passingYear;
  String marksOrGrade;
  int orderIndex;

  EducationItem({
    this.id,
    this.cvId,
    this.degree = '',
    this.institution = '',
    this.city = '',
    this.passingYear = '',
    this.marksOrGrade = '',
    this.orderIndex = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (cvId != null) 'cv_id': cvId,
      'degree': degree,
      'institution': institution,
      'city': city,
      'passing_year': passingYear,
      'marks_or_grade': marksOrGrade,
      'order_index': orderIndex,
    };
  }

  factory EducationItem.fromMap(Map<String, dynamic> map) {
    return EducationItem(
      id: map['id'] as int?,
      cvId: map['cv_id'] as int?,
      degree: map['degree'] as String? ?? '',
      institution: map['institution'] as String? ?? '',
      city: map['city'] as String? ?? '',
      passingYear: map['passing_year'] as String? ?? '',
      marksOrGrade: map['marks_or_grade'] as String? ?? '',
      orderIndex: map['order_index'] as int? ?? 0,
    );
  }

  EducationItem copy() {
    return EducationItem(
      degree: degree,
      institution: institution,
      city: city,
      passingYear: passingYear,
      marksOrGrade: marksOrGrade,
      orderIndex: orderIndex,
    );
  }
}

class ExperienceItem {
  int? id;
  int? cvId;
  String jobTitle;
  String company;
  String city;
  String startDate;
  String endDate;
  bool isCurrent;
  String description;
  int orderIndex;

  ExperienceItem({
    this.id,
    this.cvId,
    this.jobTitle = '',
    this.company = '',
    this.city = '',
    this.startDate = '',
    this.endDate = '',
    this.isCurrent = false,
    this.description = '',
    this.orderIndex = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (cvId != null) 'cv_id': cvId,
      'job_title': jobTitle,
      'company': company,
      'city': city,
      'start_date': startDate,
      'end_date': endDate,
      'is_current': isCurrent ? 1 : 0,
      'description': description,
      'order_index': orderIndex,
    };
  }

  factory ExperienceItem.fromMap(Map<String, dynamic> map) {
    return ExperienceItem(
      id: map['id'] as int?,
      cvId: map['cv_id'] as int?,
      jobTitle: map['job_title'] as String? ?? '',
      company: map['company'] as String? ?? '',
      city: map['city'] as String? ?? '',
      startDate: map['start_date'] as String? ?? '',
      endDate: map['end_date'] as String? ?? '',
      isCurrent: (map['is_current'] as int? ?? 0) == 1,
      description: map['description'] as String? ?? '',
      orderIndex: map['order_index'] as int? ?? 0,
    );
  }

  ExperienceItem copy() {
    return ExperienceItem(
      jobTitle: jobTitle,
      company: company,
      city: city,
      startDate: startDate,
      endDate: endDate,
      isCurrent: isCurrent,
      description: description,
      orderIndex: orderIndex,
    );
  }
}

class SkillItem {
  int? id;
  int? cvId;
  String skillName;
  String level;
  int orderIndex;

  SkillItem({
    this.id,
    this.cvId,
    this.skillName = '',
    this.level = '',
    this.orderIndex = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (cvId != null) 'cv_id': cvId,
      'skill_name': skillName,
      'level': level,
      'order_index': orderIndex,
    };
  }

  factory SkillItem.fromMap(Map<String, dynamic> map) {
    return SkillItem(
      id: map['id'] as int?,
      cvId: map['cv_id'] as int?,
      skillName: map['skill_name'] as String? ?? '',
      level: map['level'] as String? ?? '',
      orderIndex: map['order_index'] as int? ?? 0,
    );
  }

  SkillItem copy() {
    return SkillItem(
      skillName: skillName,
      level: level,
      orderIndex: orderIndex,
    );
  }
}

class LanguageItem {
  int? id;
  int? cvId;
  String languageName;
  String proficiency;
  int orderIndex;

  LanguageItem({
    this.id,
    this.cvId,
    this.languageName = '',
    this.proficiency = '',
    this.orderIndex = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (cvId != null) 'cv_id': cvId,
      'language_name': languageName,
      'proficiency': proficiency,
      'order_index': orderIndex,
    };
  }

  factory LanguageItem.fromMap(Map<String, dynamic> map) {
    return LanguageItem(
      id: map['id'] as int?,
      cvId: map['cv_id'] as int?,
      languageName: map['language_name'] as String? ?? '',
      proficiency: map['proficiency'] as String? ?? '',
      orderIndex: map['order_index'] as int? ?? 0,
    );
  }

  LanguageItem copy() {
    return LanguageItem(
      languageName: languageName,
      proficiency: proficiency,
      orderIndex: orderIndex,
    );
  }
}

class ProjectItem {
  int? id;
  int? cvId;
  String title;
  String description;
  String linkOrTools;
  int orderIndex;

  ProjectItem({
    this.id,
    this.cvId,
    this.title = '',
    this.description = '',
    this.linkOrTools = '',
    this.orderIndex = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (cvId != null) 'cv_id': cvId,
      'title': title,
      'description': description,
      'link_or_tools': linkOrTools,
      'order_index': orderIndex,
    };
  }

  factory ProjectItem.fromMap(Map<String, dynamic> map) {
    return ProjectItem(
      id: map['id'] as int?,
      cvId: map['cv_id'] as int?,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      linkOrTools: map['link_or_tools'] as String? ?? '',
      orderIndex: map['order_index'] as int? ?? 0,
    );
  }

  ProjectItem copy() {
    return ProjectItem(
      title: title,
      description: description,
      linkOrTools: linkOrTools,
      orderIndex: orderIndex,
    );
  }
}

class CertificationItem {
  int? id;
  int? cvId;
  String title;
  String institute;
  String year;
  int orderIndex;

  CertificationItem({
    this.id,
    this.cvId,
    this.title = '',
    this.institute = '',
    this.year = '',
    this.orderIndex = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (cvId != null) 'cv_id': cvId,
      'title': title,
      'institute': institute,
      'year': year,
      'order_index': orderIndex,
    };
  }

  factory CertificationItem.fromMap(Map<String, dynamic> map) {
    return CertificationItem(
      id: map['id'] as int?,
      cvId: map['cv_id'] as int?,
      title: map['title'] as String? ?? '',
      institute: map['institute'] as String? ?? '',
      year: map['year'] as String? ?? '',
      orderIndex: map['order_index'] as int? ?? 0,
    );
  }

  CertificationItem copy() {
    return CertificationItem(
      title: title,
      institute: institute,
      year: year,
      orderIndex: orderIndex,
    );
  }
}

class ReferenceItem {
  int? id;
  int? cvId;
  String name;
  String designation;
  String contact;
  int orderIndex;

  ReferenceItem({
    this.id,
    this.cvId,
    this.name = '',
    this.designation = '',
    this.contact = '',
    this.orderIndex = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (cvId != null) 'cv_id': cvId,
      'name': name,
      'designation': designation,
      'contact': contact,
      'order_index': orderIndex,
    };
  }

  factory ReferenceItem.fromMap(Map<String, dynamic> map) {
    return ReferenceItem(
      id: map['id'] as int?,
      cvId: map['cv_id'] as int?,
      name: map['name'] as String? ?? '',
      designation: map['designation'] as String? ?? '',
      contact: map['contact'] as String? ?? '',
      orderIndex: map['order_index'] as int? ?? 0,
    );
  }

  ReferenceItem copy() {
    return ReferenceItem(
      name: name,
      designation: designation,
      contact: contact,
      orderIndex: orderIndex,
    );
  }
}

class HobbyItem {
  int? id;
  int? cvId;
  String name;
  int orderIndex;

  HobbyItem({
    this.id,
    this.cvId,
    this.name = '',
    this.orderIndex = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (cvId != null) 'cv_id': cvId,
      'name': name,
      'order_index': orderIndex,
    };
  }

  factory HobbyItem.fromMap(Map<String, dynamic> map) {
    return HobbyItem(
      id: map['id'] as int?,
      cvId: map['cv_id'] as int?,
      name: map['name'] as String? ?? '',
      orderIndex: map['order_index'] as int? ?? 0,
    );
  }

  HobbyItem copy() {
    return HobbyItem(
      name: name,
      orderIndex: orderIndex,
    );
  }
}

class CvModel {
  int? id;
  String title;
  String template; // 'classic', 'modern', 'minimal', 'photo'
  String? photoPath;
  String objective;
  String createdAt;
  String updatedAt;

  PersonalDetails personal;
  List<EducationItem> education;
  List<ExperienceItem> experience;
  List<SkillItem> skills;
  List<LanguageItem> languages;
  List<ProjectItem> projects;
  List<CertificationItem> certifications;
  List<ReferenceItem> references;
  List<HobbyItem> hobbies;

  CvModel({
    this.id,
    required this.title,
    this.template = 'classic',
    this.photoPath,
    this.objective = '',
    required this.createdAt,
    required this.updatedAt,
    PersonalDetails? personal,
    List<EducationItem>? education,
    List<ExperienceItem>? experience,
    List<SkillItem>? skills,
    List<LanguageItem>? languages,
    List<ProjectItem>? projects,
    List<CertificationItem>? certifications,
    List<ReferenceItem>? references,
    List<HobbyItem>? hobbies,
  })  : personal = personal ?? PersonalDetails(),
        education = education ?? [],
        experience = experience ?? [],
        skills = skills ?? [],
        languages = languages ?? [],
        projects = projects ?? [],
        certifications = certifications ?? [],
        references = references ?? [],
        hobbies = hobbies ?? [];

  Map<String, dynamic> toCvRowMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'template': template,
      'photo_path': photoPath,
      'objective': objective,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory CvModel.fromCvRowMap(Map<String, dynamic> map) {
    return CvModel(
      id: map['id'] as int?,
      title: map['title'] as String? ?? 'Untitled CV',
      template: map['template'] as String? ?? 'classic',
      photoPath: map['photo_path'] as String?,
      objective: map['objective'] as String? ?? '',
      createdAt: map['created_at'] as String? ?? '',
      updatedAt: map['updated_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJsonMap() {
    return {
      'id': id,
      'title': title,
      'template': template,
      'photo_path': photoPath,
      'objective': objective,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'personal': personal.toMap(),
      'education': education.map((e) => e.toMap()).toList(),
      'experience': experience.map((e) => e.toMap()).toList(),
      'skills': skills.map((e) => e.toMap()).toList(),
      'languages': languages.map((e) => e.toMap()).toList(),
      'projects': projects.map((e) => e.toMap()).toList(),
      'certifications': certifications.map((e) => e.toMap()).toList(),
      'references': references.map((e) => e.toMap()).toList(),
      'hobbies': hobbies.map((e) => e.toMap()).toList(),
    };
  }

  factory CvModel.fromJsonMap(Map<String, dynamic> json) {
    final cv = CvModel(
      id: json['id'] as int?,
      title: json['title'] as String? ?? 'Untitled CV',
      template: json['template'] as String? ?? 'classic',
      photoPath: json['photo_path'] as String?,
      objective: json['objective'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      updatedAt: json['updated_at'] as String? ?? DateTime.now().toIso8601String(),
      personal: json['personal'] != null
          ? PersonalDetails.fromMap(Map<String, dynamic>.from(json['personal'] as Map))
          : PersonalDetails(),
    );

    if (json['education'] is List) {
      cv.education = (json['education'] as List)
          .map((e) => EducationItem.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    if (json['experience'] is List) {
      cv.experience = (json['experience'] as List)
          .map((e) => ExperienceItem.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    if (json['skills'] is List) {
      cv.skills = (json['skills'] as List)
          .map((e) => SkillItem.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    if (json['languages'] is List) {
      cv.languages = (json['languages'] as List)
          .map((e) => LanguageItem.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    if (json['projects'] is List) {
      cv.projects = (json['projects'] as List)
          .map((e) => ProjectItem.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    if (json['certifications'] is List) {
      cv.certifications = (json['certifications'] as List)
          .map((e) => CertificationItem.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    if (json['references'] is List) {
      cv.references = (json['references'] as List)
          .map((e) => ReferenceItem.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    if (json['hobbies'] is List) {
      cv.hobbies = (json['hobbies'] as List)
          .map((e) => HobbyItem.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    return cv;
  }

  CvModel deepCopy({String? newTitle}) {
    return CvModel(
      title: newTitle ?? '$title (Copy)',
      template: template,
      photoPath: photoPath,
      objective: objective,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
      personal: personal.copyWith(),
      education: education.map((e) => e.copy()).toList(),
      experience: experience.map((e) => e.copy()).toList(),
      skills: skills.map((e) => e.copy()).toList(),
      languages: languages.map((e) => e.copy()).toList(),
      projects: projects.map((e) => e.copy()).toList(),
      certifications: certifications.map((e) => e.copy()).toList(),
      references: references.map((e) => e.copy()).toList(),
      hobbies: hobbies.map((e) => e.copy()).toList(),
    );
  }
}
