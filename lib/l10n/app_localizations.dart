import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_nl.dart';
import 'app_localizations_tr.dart';

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
    Locale('nl'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'İş Takibim'**
  String get appTitle;

  /// No description provided for @appLocked.
  ///
  /// In tr, this message translates to:
  /// **'Geliştirici tarafından sistem kilitlendi'**
  String get appLocked;

  /// No description provided for @appLockedHint.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama şu an kullanılamıyor. Lütfen daha sonra tekrar deneyin.'**
  String get appLockedHint;

  /// No description provided for @login.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get login;

  /// No description provided for @email.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get email;

  /// No description provided for @password.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get password;

  /// No description provided for @logout.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış'**
  String get logout;

  /// No description provided for @dashboard.
  ///
  /// In tr, this message translates to:
  /// **'Kontrol Paneli'**
  String get dashboard;

  /// No description provided for @projects.
  ///
  /// In tr, this message translates to:
  /// **'Projeler'**
  String get projects;

  /// No description provided for @workers.
  ///
  /// In tr, this message translates to:
  /// **'Personel'**
  String get workers;

  /// No description provided for @tasks.
  ///
  /// In tr, this message translates to:
  /// **'Görevler'**
  String get tasks;

  /// No description provided for @teams.
  ///
  /// In tr, this message translates to:
  /// **'Ekipler'**
  String get teams;

  /// No description provided for @analytics.
  ///
  /// In tr, this message translates to:
  /// **'Analiz'**
  String get analytics;

  /// No description provided for @archive.
  ///
  /// In tr, this message translates to:
  /// **'Arşiv'**
  String get archive;

  /// No description provided for @search.
  ///
  /// In tr, this message translates to:
  /// **'Ara'**
  String get search;

  /// No description provided for @searchHint.
  ///
  /// In tr, this message translates to:
  /// **'Proje, ev, işçi veya görev ara...'**
  String get searchHint;

  /// No description provided for @language.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get language;

  /// No description provided for @turkish.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get turkish;

  /// No description provided for @dutch.
  ///
  /// In tr, this message translates to:
  /// **'Hollandaca'**
  String get dutch;

  /// No description provided for @save.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In tr, this message translates to:
  /// **'Düzenle'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In tr, this message translates to:
  /// **'Ekle'**
  String get add;

  /// No description provided for @active.
  ///
  /// In tr, this message translates to:
  /// **'Aktif'**
  String get active;

  /// No description provided for @passive.
  ///
  /// In tr, this message translates to:
  /// **'Pasif'**
  String get passive;

  /// No description provided for @completed.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlandı'**
  String get completed;

  /// No description provided for @inProgress.
  ///
  /// In tr, this message translates to:
  /// **'Devam Ediyor'**
  String get inProgress;

  /// No description provided for @pending.
  ///
  /// In tr, this message translates to:
  /// **'Bekliyor'**
  String get pending;

  /// No description provided for @overdue.
  ///
  /// In tr, this message translates to:
  /// **'Gecikmiş'**
  String get overdue;

  /// No description provided for @missingWork.
  ///
  /// In tr, this message translates to:
  /// **'Eksik İş Var'**
  String get missingWork;

  /// No description provided for @dailyTasks.
  ///
  /// In tr, this message translates to:
  /// **'Günlük İşler'**
  String get dailyTasks;

  /// No description provided for @weeklyTasks.
  ///
  /// In tr, this message translates to:
  /// **'Haftalık İşler'**
  String get weeklyTasks;

  /// No description provided for @completedTasks.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlanan İşler'**
  String get completedTasks;

  /// No description provided for @pendingTasks.
  ///
  /// In tr, this message translates to:
  /// **'Bekleyen İşler'**
  String get pendingTasks;

  /// No description provided for @overdueTasks.
  ///
  /// In tr, this message translates to:
  /// **'Geciken İşler'**
  String get overdueTasks;

  /// No description provided for @workerPerformance.
  ///
  /// In tr, this message translates to:
  /// **'İşçi Performansı'**
  String get workerPerformance;

  /// No description provided for @projectProgress.
  ///
  /// In tr, this message translates to:
  /// **'Proje İlerlemesi'**
  String get projectProgress;

  /// No description provided for @todayTasks.
  ///
  /// In tr, this message translates to:
  /// **'Bugünkü Görevler'**
  String get todayTasks;

  /// No description provided for @projectLabel.
  ///
  /// In tr, this message translates to:
  /// **'Proje'**
  String get projectLabel;

  /// No description provided for @houseLabel.
  ///
  /// In tr, this message translates to:
  /// **'Ev'**
  String get houseLabel;

  /// No description provided for @workItems.
  ///
  /// In tr, this message translates to:
  /// **'Yapılacak İşler'**
  String get workItems;

  /// No description provided for @markComplete.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlandı'**
  String get markComplete;

  /// No description provided for @approve.
  ///
  /// In tr, this message translates to:
  /// **'Onayla'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In tr, this message translates to:
  /// **'Eksik Var'**
  String get reject;

  /// No description provided for @addNote.
  ///
  /// In tr, this message translates to:
  /// **'Not ekle'**
  String get addNote;

  /// No description provided for @addPhoto.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf ekle'**
  String get addPhoto;

  /// No description provided for @newTask.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Görev'**
  String get newTask;

  /// No description provided for @assignWorkers.
  ///
  /// In tr, this message translates to:
  /// **'İşçi Ata'**
  String get assignWorkers;

  /// No description provided for @assignedTo.
  ///
  /// In tr, this message translates to:
  /// **'Atanan'**
  String get assignedTo;

  /// No description provided for @priority.
  ///
  /// In tr, this message translates to:
  /// **'Öncelik'**
  String get priority;

  /// No description provided for @dueDate.
  ///
  /// In tr, this message translates to:
  /// **'Tarih'**
  String get dueDate;

  /// No description provided for @description.
  ///
  /// In tr, this message translates to:
  /// **'Açıklama'**
  String get description;

  /// No description provided for @low.
  ///
  /// In tr, this message translates to:
  /// **'Düşük'**
  String get low;

  /// No description provided for @medium.
  ///
  /// In tr, this message translates to:
  /// **'Orta'**
  String get medium;

  /// No description provided for @high.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek'**
  String get high;

  /// No description provided for @companyName.
  ///
  /// In tr, this message translates to:
  /// **'Şirket Adı'**
  String get companyName;

  /// No description provided for @address.
  ///
  /// In tr, this message translates to:
  /// **'Adres'**
  String get address;

  /// No description provided for @city.
  ///
  /// In tr, this message translates to:
  /// **'Şehir'**
  String get city;

  /// No description provided for @buildingNumber.
  ///
  /// In tr, this message translates to:
  /// **'İnşaat / Ev Numarası'**
  String get buildingNumber;

  /// No description provided for @startDate.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç Tarihi'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş Tarihi'**
  String get endDate;

  /// No description provided for @projectStatus.
  ///
  /// In tr, this message translates to:
  /// **'Proje Durumu'**
  String get projectStatus;

  /// No description provided for @houseNumber.
  ///
  /// In tr, this message translates to:
  /// **'Ev Numarası'**
  String get houseNumber;

  /// No description provided for @apartmentNumber.
  ///
  /// In tr, this message translates to:
  /// **'Daire Numarası'**
  String get apartmentNumber;

  /// No description provided for @floor.
  ///
  /// In tr, this message translates to:
  /// **'Kat'**
  String get floor;

  /// No description provided for @block.
  ///
  /// In tr, this message translates to:
  /// **'Blok'**
  String get block;

  /// No description provided for @room.
  ///
  /// In tr, this message translates to:
  /// **'Oda'**
  String get room;

  /// No description provided for @units.
  ///
  /// In tr, this message translates to:
  /// **'Ev / Daireler'**
  String get units;

  /// No description provided for @createWorker.
  ///
  /// In tr, this message translates to:
  /// **'İşçi Oluştur'**
  String get createWorker;

  /// No description provided for @workerName.
  ///
  /// In tr, this message translates to:
  /// **'İşçi Adı'**
  String get workerName;

  /// No description provided for @noTasksToday.
  ///
  /// In tr, this message translates to:
  /// **'Bugün görev yok'**
  String get noTasksToday;

  /// No description provided for @noAssignedTasks.
  ///
  /// In tr, this message translates to:
  /// **'Size atanmış görev yok'**
  String get noAssignedTasks;

  /// No description provided for @upcomingTasks.
  ///
  /// In tr, this message translates to:
  /// **'Yaklaşan Görevler'**
  String get upcomingTasks;

  /// No description provided for @loginError.
  ///
  /// In tr, this message translates to:
  /// **'Giriş başarısız'**
  String get loginError;

  /// No description provided for @welcomeAdmin.
  ///
  /// In tr, this message translates to:
  /// **'Yönetici Paneli'**
  String get welcomeAdmin;

  /// No description provided for @welcomeWorker.
  ///
  /// In tr, this message translates to:
  /// **'İşçi Paneli'**
  String get welcomeWorker;

  /// No description provided for @notifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get notifications;

  /// No description provided for @filter.
  ///
  /// In tr, this message translates to:
  /// **'Filtrele'**
  String get filter;

  /// No description provided for @fastestWorker.
  ///
  /// In tr, this message translates to:
  /// **'En Hızlı Çalışan'**
  String get fastestWorker;

  /// No description provided for @mostDelayed.
  ///
  /// In tr, this message translates to:
  /// **'En Çok Geciken'**
  String get mostDelayed;

  /// No description provided for @ongoingProjects.
  ///
  /// In tr, this message translates to:
  /// **'Devam Eden Projeler'**
  String get ongoingProjects;

  /// No description provided for @onHold.
  ///
  /// In tr, this message translates to:
  /// **'Beklemede'**
  String get onHold;

  /// No description provided for @bulkAssign.
  ///
  /// In tr, this message translates to:
  /// **'Toplu Ata'**
  String get bulkAssign;

  /// No description provided for @checklist.
  ///
  /// In tr, this message translates to:
  /// **'Kontrol Listesi'**
  String get checklist;

  /// No description provided for @addChecklistItem.
  ///
  /// In tr, this message translates to:
  /// **'İş kalemi ekle'**
  String get addChecklistItem;

  /// No description provided for @confirmDelete.
  ///
  /// In tr, this message translates to:
  /// **'Silmek istediğinize emin misiniz?'**
  String get confirmDelete;

  /// No description provided for @yes.
  ///
  /// In tr, this message translates to:
  /// **'Evet'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In tr, this message translates to:
  /// **'Hayır'**
  String get no;

  /// No description provided for @adminLogin.
  ///
  /// In tr, this message translates to:
  /// **'Yönetici Girişi'**
  String get adminLogin;

  /// No description provided for @workerLogin.
  ///
  /// In tr, this message translates to:
  /// **'Personel Girişi'**
  String get workerLogin;

  /// No description provided for @setPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifre Belirle'**
  String get setPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifre Tekrar'**
  String get confirmPassword;

  /// No description provided for @continueBtn.
  ///
  /// In tr, this message translates to:
  /// **'Devam'**
  String get continueBtn;

  /// No description provided for @firstLoginHint.
  ///
  /// In tr, this message translates to:
  /// **'İlk girişiniz. Lütfen şifrenizi belirleyin.'**
  String get firstLoginHint;

  /// No description provided for @pendingSetup.
  ///
  /// In tr, this message translates to:
  /// **'Şifre bekliyor'**
  String get pendingSetup;

  /// No description provided for @inviteWorker.
  ///
  /// In tr, this message translates to:
  /// **'Personel Ekle (E-posta)'**
  String get inviteWorker;
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
      <String>['nl', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'nl':
      return AppLocalizationsNl();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
