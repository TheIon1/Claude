ALTER TABLE public.r_expert ADD id bigserial NOT NULL;
ALTER TABLE public.r_expert ALTER COLUMN id SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.id IS 'Идентификатор версии записи справочника';
 
ALTER TABLE public.r_expert ADD create_date timestamptz DEFAULT now() NOT NULL;
ALTER TABLE public.r_expert ALTER COLUMN create_date SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.create_date IS 'Дата создания';
 
ALTER TABLE public.r_expert ADD author_id varchar(100) NOT NULL;
ALTER TABLE public.r_expert ALTER COLUMN author_id SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.author_id IS 'Автор';
 
ALTER TABLE public.r_expert ADD date_from timestamptz NULL;
ALTER TABLE public.r_expert ALTER COLUMN date_from SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.date_from IS 'Версия записи действительна с';
 
ALTER TABLE public.r_expert ADD date_to timestamptz NULL;
ALTER TABLE public.r_expert ALTER COLUMN date_to SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.date_to IS 'Версия записи действительна по';
 
ALTER TABLE public.r_expert ADD active bool DEFAULT true NOT NULL;
ALTER TABLE public.r_expert ALTER COLUMN active SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.active IS 'Версия записи актуальна';
 
ALTER TABLE public.r_expert ADD "uuid" uuid NOT NULL;
ALTER TABLE public.r_expert ALTER COLUMN "uuid" SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert."uuid" IS 'Уникальный идентификатор записи справочника';
 
ALTER TABLE public.r_expert ADD family_name varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN family_name SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.family_name IS 'Фамилия';
 
ALTER TABLE public.r_expert ADD first_name varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN first_name SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.first_name IS 'Имя';
 
ALTER TABLE public.r_expert ADD middle_name varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN middle_name SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.middle_name IS 'Отчество';
 
ALTER TABLE public.r_expert ADD passport_series varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN passport_series SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.passport_series IS 'Серия паспорта';
 
ALTER TABLE public.r_expert ADD passport_number varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN passport_number SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.passport_number IS 'Номер паспорта';
 
ALTER TABLE public.r_expert ADD passport_issue_date date NULL;
ALTER TABLE public.r_expert ALTER COLUMN passport_issue_date SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.passport_issue_date IS 'Дата выдачи паспорта';
 
ALTER TABLE public.r_expert ADD passport_provider varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN passport_provider SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.passport_provider IS 'Выдавший орган';
 
ALTER TABLE public.r_expert ADD passport_provider_code varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN passport_provider_code SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.passport_provider_code IS 'Код подразделения';
 
ALTER TABLE public.r_expert ADD snils varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN snils SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.snils IS 'СНИЛС';
 
ALTER TABLE public.r_expert ADD "position" varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN "position" SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert."position" IS 'Должность';
 
ALTER TABLE public.r_expert ADD work_place varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN work_place SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.work_place IS 'Место работы';
 
ALTER TABLE public.r_expert ADD phone_number varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN phone_number SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.phone_number IS 'Контактный телефон, включая код города';
 
ALTER TABLE public.r_expert ADD fax varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN fax SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.fax IS 'Факс';
 
ALTER TABLE public.r_expert ADD email varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN email SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.email IS 'Электронная почта';
 
ALTER TABLE public.r_expert ADD import_boolean bool NULL;
ALTER TABLE public.r_expert ALTER COLUMN import_boolean SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.import_boolean IS 'Ввоз';
 
ALTER TABLE public.r_expert ADD temporary_export_boolean bool NULL;
ALTER TABLE public.r_expert ALTER COLUMN temporary_export_boolean SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.temporary_export_boolean IS 'Временный вывоз';
 
ALTER TABLE public.r_expert ADD constant_export_boolean bool NULL;
ALTER TABLE public.r_expert ALTER COLUMN constant_export_boolean SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.constant_export_boolean IS 'Постоянный вывоз';
 
ALTER TABLE public.r_expert ADD weapon_boolean bool NULL;
ALTER TABLE public.r_expert ALTER COLUMN weapon_boolean SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.weapon_boolean IS 'Оружие';
 
ALTER TABLE public.r_expert ADD law_request_boolean bool NULL;
ALTER TABLE public.r_expert ALTER COLUMN law_request_boolean SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.law_request_boolean IS 'По запросу правоохранительных органов';
 
ALTER TABLE public.r_expert ADD order_number varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN order_number SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.order_number IS 'Приказ №';
 
ALTER TABLE public.r_expert ADD order_date date NULL;
ALTER TABLE public.r_expert ALTER COLUMN order_date SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.order_date IS 'От';
 
ALTER TABLE public.r_expert ADD not_performing_boolean bool NULL;
ALTER TABLE public.r_expert ALTER COLUMN not_performing_boolean SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.not_performing_boolean IS 'Временно не осуществляет экспертизу';
 
ALTER TABLE public.r_expert ADD "comment" text NULL;
ALTER TABLE public.r_expert ALTER COLUMN "comment" SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert."comment" IS 'Комментарий';
 
ALTER TABLE public.r_expert ADD federal_region varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN federal_region SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.federal_region IS 'Федеральный округ проживания';
 
ALTER TABLE public.r_expert ADD post_index varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN post_index SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.post_index IS 'Индекс';
 
ALTER TABLE public.r_expert ADD living_federal_region varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN living_federal_region SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.living_federal_region IS 'Регион';
 
ALTER TABLE public.r_expert ADD living_rayon varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN living_rayon SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.living_rayon IS 'Район';
 
ALTER TABLE public.r_expert ADD living_city varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN living_city SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.living_city IS 'Город';
 
ALTER TABLE public.r_expert ADD living_locality varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN living_locality SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.living_locality IS 'Населенный пункт';
 
ALTER TABLE public.r_expert ADD living_street varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN living_street SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.living_street IS 'Улица';
 
ALTER TABLE public.r_expert ADD living_home varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN living_home SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.living_home IS 'Номер дома';
 
ALTER TABLE public.r_expert ADD living_building varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN living_building SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.living_building IS 'Корпус/Строение';
 
ALTER TABLE public.r_expert ADD living_apartment_number varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN living_apartment_number SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.living_apartment_number IS 'Квартира/Офис';
 
ALTER TABLE public.r_expert ADD full_address text NULL;
ALTER TABLE public.r_expert ALTER COLUMN full_address SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.full_address IS 'Адрес одной строкой';
 
ALTER TABLE public.r_expert ADD education text NULL;
ALTER TABLE public.r_expert ALTER COLUMN education SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.education IS 'Образование';
 
ALTER TABLE public.r_expert ADD certificate_number varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN certificate_number SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.certificate_number IS 'Номер удостоверения эксперта';
 
ALTER TABLE public.r_expert ADD certificate_date date NULL;
ALTER TABLE public.r_expert ALTER COLUMN certificate_date SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.certificate_date IS 'Дата выдачи удостоверения';
 
ALTER TABLE public.r_expert ADD stop_reason varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN stop_reason SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.stop_reason IS 'Причина приостановления деятельности';
 
ALTER TABLE public.r_expert ADD stop_basis varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN stop_basis SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.stop_basis IS 'Основание приостановления деятельности';
 
ALTER TABLE public.r_expert ADD certificate_expire_date date NULL;
ALTER TABLE public.r_expert ALTER COLUMN certificate_expire_date SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.certificate_expire_date IS 'Дата окончания действия удостоверения';   
ALTER TABLE public.r_expert_specialization ADD id bigserial NOT NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN id SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert_specialization.id IS 'Идентификатор версии записи справочника';
 
ALTER TABLE public.r_expert_specialization ADD create_date timestamptz DEFAULT now() NOT NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN create_date SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert_specialization.create_date IS 'Дата создания';
 
ALTER TABLE public.r_expert_specialization ADD author_id varchar(100) NOT NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN author_id SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert_specialization.author_id IS 'Автор';
 
ALTER TABLE public.r_expert_specialization ADD date_from timestamptz NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN date_from SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert_specialization.date_from IS 'Версия записи действительна с';
 
ALTER TABLE public.r_expert_specialization ADD date_to timestamptz NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN date_to SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert_specialization.date_to IS 'Версия записи действительна по';
 
ALTER TABLE public.r_expert_specialization ADD active bool DEFAULT true NOT NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN active SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert_specialization.active IS 'Версия записи актуальна';
 
ALTER TABLE public.r_expert_specialization ADD "uuid" uuid NOT NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN "uuid" SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert_specialization."uuid" IS 'Уникальный идентификатор записи справочника';
 
ALTER TABLE public.r_expert_specialization ADD expert_id int8 NOT NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN expert_id SET STORAGE PLAIN;
 
ALTER TABLE public.r_expert_specialization ADD attestation_order varchar(255) NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN attestation_order SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert_specialization.attestation_order IS 'Приказ об аттестации';
 
ALTER TABLE public.r_expert_specialization ADD attestation_expire_date date NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN attestation_expire_date SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert_specialization.attestation_expire_date IS 'Срок действия';
 
ALTER TABLE public.r_expert_specialization ADD attestation_date date NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN attestation_date SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert_specialization.attestation_date IS 'Дата аттестации';
 
ALTER TABLE public.r_expert_specialization ADD details text NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN details SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert_specialization.details IS 'Детализация';
 
ALTER TABLE public.r_expert_specialization ADD object_category text DEFAULT 'painting'::text NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN object_category SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert_specialization.object_category IS 'Категория культурной ценности (Приказ № 780)';
 
ALTER TABLE public.r_expert_specialization ADD item_order int8 NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN item_order SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert_specialization.item_order IS 'Порядковый номер';
 
ALTER TABLE public.r_expert_specialization ADD specialization_date date NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN specialization_date SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert_specialization.specialization_date IS 'Дата начала действия специализации';
 
ALTER TABLE public.r_expert_specialization ADD specialization_expire_date date NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN specialization_expire_date SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert_specialization.specialization_expire_date IS 'Дата окончания действия специализации';
 
ALTER TABLE public.r_expert_specialization ADD region varchar(255) NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN region SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert_specialization.region IS 'Регион';
 
ALTER TABLE public.r_expert_specialization ADD detail_start_period text DEFAULT 'i'::text NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN detail_start_period SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert_specialization.detail_start_period IS 'Период от';
 
ALTER TABLE public.r_expert_specialization ADD detail_end_period text DEFAULT 'ii'::text NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN detail_end_period SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert_specialization.detail_end_period IS 'Период до';
ALTER TABLE public.r_expert ADD id bigserial NOT NULL;
ALTER TABLE public.r_expert ALTER COLUMN id SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.id IS 'Идентификатор версии записи справочника';
 
ALTER TABLE public.r_expert ADD create_date timestamptz DEFAULT now() NOT NULL;
ALTER TABLE public.r_expert ALTER COLUMN create_date SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.create_date IS 'Дата создания';
 
ALTER TABLE public.r_expert ADD author_id varchar(100) NOT NULL;
ALTER TABLE public.r_expert ALTER COLUMN author_id SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.author_id IS 'Автор';
 
ALTER TABLE public.r_expert ADD date_from timestamptz NULL;
ALTER TABLE public.r_expert ALTER COLUMN date_from SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.date_from IS 'Версия записи действительна с';
 
ALTER TABLE public.r_expert ADD date_to timestamptz NULL;
ALTER TABLE public.r_expert ALTER COLUMN date_to SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.date_to IS 'Версия записи действительна по';
 
ALTER TABLE public.r_expert ADD active bool DEFAULT true NOT NULL;
ALTER TABLE public.r_expert ALTER COLUMN active SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.active IS 'Версия записи актуальна';
 
ALTER TABLE public.r_expert ADD "uuid" uuid NOT NULL;
ALTER TABLE public.r_expert ALTER COLUMN "uuid" SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert."uuid" IS 'Уникальный идентификатор записи справочника';
 
ALTER TABLE public.r_expert ADD family_name varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN family_name SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.family_name IS 'Фамилия';
 
ALTER TABLE public.r_expert ADD first_name varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN first_name SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.first_name IS 'Имя';
 
ALTER TABLE public.r_expert ADD middle_name varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN middle_name SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.middle_name IS 'Отчество';
 
ALTER TABLE public.r_expert ADD passport_series varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN passport_series SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.passport_series IS 'Серия паспорта';
 
ALTER TABLE public.r_expert ADD passport_number varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN passport_number SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.passport_number IS 'Номер паспорта';
 
ALTER TABLE public.r_expert ADD passport_issue_date date NULL;
ALTER TABLE public.r_expert ALTER COLUMN passport_issue_date SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.passport_issue_date IS 'Дата выдачи паспорта';
 
ALTER TABLE public.r_expert ADD passport_provider varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN passport_provider SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.passport_provider IS 'Выдавший орган';
 
ALTER TABLE public.r_expert ADD passport_provider_code varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN passport_provider_code SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.passport_provider_code IS 'Код подразделения';
 
ALTER TABLE public.r_expert ADD snils varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN snils SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.snils IS 'СНИЛС';
 
ALTER TABLE public.r_expert ADD "position" varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN "position" SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert."position" IS 'Должность';
 
ALTER TABLE public.r_expert ADD work_place varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN work_place SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.work_place IS 'Место работы';
 
ALTER TABLE public.r_expert ADD phone_number varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN phone_number SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.phone_number IS 'Контактный телефон, включая код города';
 
ALTER TABLE public.r_expert ADD fax varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN fax SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.fax IS 'Факс';
 
ALTER TABLE public.r_expert ADD email varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN email SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.email IS 'Электронная почта';
 
ALTER TABLE public.r_expert ADD import_boolean bool NULL;
ALTER TABLE public.r_expert ALTER COLUMN import_boolean SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.import_boolean IS 'Ввоз';
 
ALTER TABLE public.r_expert ADD temporary_export_boolean bool NULL;
ALTER TABLE public.r_expert ALTER COLUMN temporary_export_boolean SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.temporary_export_boolean IS 'Временный вывоз';
 
ALTER TABLE public.r_expert ADD constant_export_boolean bool NULL;
ALTER TABLE public.r_expert ALTER COLUMN constant_export_boolean SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.constant_export_boolean IS 'Постоянный вывоз';
 
ALTER TABLE public.r_expert ADD weapon_boolean bool NULL;
ALTER TABLE public.r_expert ALTER COLUMN weapon_boolean SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.weapon_boolean IS 'Оружие';
 
ALTER TABLE public.r_expert ADD law_request_boolean bool NULL;
ALTER TABLE public.r_expert ALTER COLUMN law_request_boolean SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.law_request_boolean IS 'По запросу правоохранительных органов';
 
ALTER TABLE public.r_expert ADD order_number varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN order_number SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.order_number IS 'Приказ №';
 
ALTER TABLE public.r_expert ADD order_date date NULL;
ALTER TABLE public.r_expert ALTER COLUMN order_date SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.order_date IS 'От';
 
ALTER TABLE public.r_expert ADD not_performing_boolean bool NULL;
ALTER TABLE public.r_expert ALTER COLUMN not_performing_boolean SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.not_performing_boolean IS 'Временно не осуществляет экспертизу';
 
ALTER TABLE public.r_expert ADD "comment" text NULL;
ALTER TABLE public.r_expert ALTER COLUMN "comment" SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert."comment" IS 'Комментарий';
 
ALTER TABLE public.r_expert ADD federal_region varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN federal_region SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.federal_region IS 'Федеральный округ проживания';
 
ALTER TABLE public.r_expert ADD post_index varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN post_index SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.post_index IS 'Индекс';
 
ALTER TABLE public.r_expert ADD living_federal_region varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN living_federal_region SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.living_federal_region IS 'Регион';
 
ALTER TABLE public.r_expert ADD living_rayon varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN living_rayon SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.living_rayon IS 'Район';
 
ALTER TABLE public.r_expert ADD living_city varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN living_city SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.living_city IS 'Город';
 
ALTER TABLE public.r_expert ADD living_locality varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN living_locality SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.living_locality IS 'Населенный пункт';
 
ALTER TABLE public.r_expert ADD living_street varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN living_street SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.living_street IS 'Улица';
 
ALTER TABLE public.r_expert ADD living_home varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN living_home SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.living_home IS 'Номер дома';
 
ALTER TABLE public.r_expert ADD living_building varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN living_building SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.living_building IS 'Корпус/Строение';
 
ALTER TABLE public.r_expert ADD living_apartment_number varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN living_apartment_number SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.living_apartment_number IS 'Квартира/Офис';
 
ALTER TABLE public.r_expert ADD full_address text NULL;
ALTER TABLE public.r_expert ALTER COLUMN full_address SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.full_address IS 'Адрес одной строкой';
 
ALTER TABLE public.r_expert ADD education text NULL;
ALTER TABLE public.r_expert ALTER COLUMN education SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.education IS 'Образование';
 
ALTER TABLE public.r_expert ADD certificate_number varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN certificate_number SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.certificate_number IS 'Номер удостоверения эксперта';
 
ALTER TABLE public.r_expert ADD certificate_date date NULL;
ALTER TABLE public.r_expert ALTER COLUMN certificate_date SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.certificate_date IS 'Дата выдачи удостоверения';
 
ALTER TABLE public.r_expert ADD stop_reason varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN stop_reason SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.stop_reason IS 'Причина приостановления деятельности';
 
ALTER TABLE public.r_expert ADD stop_basis varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN stop_basis SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.stop_basis IS 'Основание приостановления деятельности';
 
ALTER TABLE public.r_expert ADD certificate_expire_date date NULL;
ALTER TABLE public.r_expert ALTER COLUMN certificate_expire_date SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.certificate_expire_date IS 'Дата окончания действия удостоверения';   
ALTER TABLE public.r_expert_specialization ADD id bigserial NOT NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN id SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert_specialization.id IS 'Идентификатор версии записи справочника';
 
ALTER TABLE public.r_expert_specialization ADD create_date timestamptz DEFAULT now() NOT NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN create_date SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert_specialization.create_date IS 'Дата создания';
 
ALTER TABLE public.r_expert_specialization ADD author_id varchar(100) NOT NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN author_id SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert_specialization.author_id IS 'Автор';
 
ALTER TABLE public.r_expert_specialization ADD date_from timestamptz NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN date_from SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert_specialization.date_from IS 'Версия записи действительна с';
 
ALTER TABLE public.r_expert_specialization ADD date_to timestamptz NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN date_to SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert_specialization.date_to IS 'Версия записи действительна по';
 
ALTER TABLE public.r_expert_specialization ADD active bool DEFAULT true NOT NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN active SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert_specialization.active IS 'Версия записи актуальна';
 
ALTER TABLE public.r_expert_specialization ADD "uuid" uuid NOT NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN "uuid" SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert_specialization."uuid" IS 'Уникальный идентификатор записи справочника';
 
ALTER TABLE public.r_expert_specialization ADD expert_id int8 NOT NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN expert_id SET STORAGE PLAIN;
 
ALTER TABLE public.r_expert_specialization ADD attestation_order varchar(255) NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN attestation_order SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert_specialization.attestation_order IS 'Приказ об аттестации';
 
ALTER TABLE public.r_expert_specialization ADD attestation_expire_date date NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN attestation_expire_date SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert_specialization.attestation_expire_date IS 'Срок действия';
 
ALTER TABLE public.r_expert_specialization ADD attestation_date date NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN attestation_date SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert_specialization.attestation_date IS 'Дата аттестации';
 
ALTER TABLE public.r_expert_specialization ADD details text NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN details SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert_specialization.details IS 'Детализация';
 
ALTER TABLE public.r_expert_specialization ADD object_category text DEFAULT 'painting'::text NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN object_category SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert_specialization.object_category IS 'Категория культурной ценности (Приказ № 780)';
 
ALTER TABLE public.r_expert_specialization ADD item_order int8 NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN item_order SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert_specialization.item_order IS 'Порядковый номер';
 
ALTER TABLE public.r_expert_specialization ADD specialization_date date NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN specialization_date SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert_specialization.specialization_date IS 'Дата начала действия специализации';
 
ALTER TABLE public.r_expert_specialization ADD specialization_expire_date date NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN specialization_expire_date SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert_specialization.specialization_expire_date IS 'Дата окончания действия специализации';
 
ALTER TABLE public.r_expert_specialization ADD region varchar(255) NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN region SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert_specialization.region IS 'Регион';
 
ALTER TABLE public.r_expert_specialization ADD detail_start_period text DEFAULT 'i'::text NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN detail_start_period SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert_specialization.detail_start_period IS 'Период от';
 
ALTER TABLE public.r_expert_specialization ADD detail_end_period text DEFAULT 'ii'::text NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN detail_end_period SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert_specialization.detail_end_period IS 'Период до';
ALTER TABLE public.r_expert ADD id bigserial NOT NULL;
ALTER TABLE public.r_expert ALTER COLUMN id SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.id IS 'Идентификатор версии записи справочника';
 
ALTER TABLE public.r_expert ADD create_date timestamptz DEFAULT now() NOT NULL;
ALTER TABLE public.r_expert ALTER COLUMN create_date SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.create_date IS 'Дата создания';
 
ALTER TABLE public.r_expert ADD author_id varchar(100) NOT NULL;
ALTER TABLE public.r_expert ALTER COLUMN author_id SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.author_id IS 'Автор';
 
ALTER TABLE public.r_expert ADD date_from timestamptz NULL;
ALTER TABLE public.r_expert ALTER COLUMN date_from SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.date_from IS 'Версия записи действительна с';
 
ALTER TABLE public.r_expert ADD date_to timestamptz NULL;
ALTER TABLE public.r_expert ALTER COLUMN date_to SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.date_to IS 'Версия записи действительна по';
 
ALTER TABLE public.r_expert ADD active bool DEFAULT true NOT NULL;
ALTER TABLE public.r_expert ALTER COLUMN active SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.active IS 'Версия записи актуальна';
 
ALTER TABLE public.r_expert ADD "uuid" uuid NOT NULL;
ALTER TABLE public.r_expert ALTER COLUMN "uuid" SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert."uuid" IS 'Уникальный идентификатор записи справочника';
 
ALTER TABLE public.r_expert ADD family_name varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN family_name SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.family_name IS 'Фамилия';
 
ALTER TABLE public.r_expert ADD first_name varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN first_name SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.first_name IS 'Имя';
 
ALTER TABLE public.r_expert ADD middle_name varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN middle_name SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.middle_name IS 'Отчество';
 
ALTER TABLE public.r_expert ADD passport_series varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN passport_series SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.passport_series IS 'Серия паспорта';
 
ALTER TABLE public.r_expert ADD passport_number varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN passport_number SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.passport_number IS 'Номер паспорта';
 
ALTER TABLE public.r_expert ADD passport_issue_date date NULL;
ALTER TABLE public.r_expert ALTER COLUMN passport_issue_date SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.passport_issue_date IS 'Дата выдачи паспорта';
 
ALTER TABLE public.r_expert ADD passport_provider varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN passport_provider SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.passport_provider IS 'Выдавший орган';
 
ALTER TABLE public.r_expert ADD passport_provider_code varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN passport_provider_code SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.passport_provider_code IS 'Код подразделения';
 
ALTER TABLE public.r_expert ADD snils varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN snils SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.snils IS 'СНИЛС';
 
ALTER TABLE public.r_expert ADD "position" varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN "position" SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert."position" IS 'Должность';
 
ALTER TABLE public.r_expert ADD work_place varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN work_place SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.work_place IS 'Место работы';
 
ALTER TABLE public.r_expert ADD phone_number varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN phone_number SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.phone_number IS 'Контактный телефон, включая код города';
 
ALTER TABLE public.r_expert ADD fax varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN fax SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.fax IS 'Факс';
 
ALTER TABLE public.r_expert ADD email varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN email SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.email IS 'Электронная почта';
 
ALTER TABLE public.r_expert ADD import_boolean bool NULL;
ALTER TABLE public.r_expert ALTER COLUMN import_boolean SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.import_boolean IS 'Ввоз';
 
ALTER TABLE public.r_expert ADD temporary_export_boolean bool NULL;
ALTER TABLE public.r_expert ALTER COLUMN temporary_export_boolean SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.temporary_export_boolean IS 'Временный вывоз';
 
ALTER TABLE public.r_expert ADD constant_export_boolean bool NULL;
ALTER TABLE public.r_expert ALTER COLUMN constant_export_boolean SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.constant_export_boolean IS 'Постоянный вывоз';
 
ALTER TABLE public.r_expert ADD weapon_boolean bool NULL;
ALTER TABLE public.r_expert ALTER COLUMN weapon_boolean SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.weapon_boolean IS 'Оружие';
 
ALTER TABLE public.r_expert ADD law_request_boolean bool NULL;
ALTER TABLE public.r_expert ALTER COLUMN law_request_boolean SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.law_request_boolean IS 'По запросу правоохранительных органов';
 
ALTER TABLE public.r_expert ADD order_number varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN order_number SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.order_number IS 'Приказ №';
 
ALTER TABLE public.r_expert ADD order_date date NULL;
ALTER TABLE public.r_expert ALTER COLUMN order_date SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.order_date IS 'От';
 
ALTER TABLE public.r_expert ADD not_performing_boolean bool NULL;
ALTER TABLE public.r_expert ALTER COLUMN not_performing_boolean SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.not_performing_boolean IS 'Временно не осуществляет экспертизу';
 
ALTER TABLE public.r_expert ADD "comment" text NULL;
ALTER TABLE public.r_expert ALTER COLUMN "comment" SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert."comment" IS 'Комментарий';
 
ALTER TABLE public.r_expert ADD federal_region varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN federal_region SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.federal_region IS 'Федеральный округ проживания';
 
ALTER TABLE public.r_expert ADD post_index varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN post_index SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.post_index IS 'Индекс';
 
ALTER TABLE public.r_expert ADD living_federal_region varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN living_federal_region SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.living_federal_region IS 'Регион';
 
ALTER TABLE public.r_expert ADD living_rayon varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN living_rayon SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.living_rayon IS 'Район';
 
ALTER TABLE public.r_expert ADD living_city varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN living_city SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.living_city IS 'Город';
 
ALTER TABLE public.r_expert ADD living_locality varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN living_locality SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.living_locality IS 'Населенный пункт';
 
ALTER TABLE public.r_expert ADD living_street varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN living_street SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.living_street IS 'Улица';
 
ALTER TABLE public.r_expert ADD living_home varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN living_home SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.living_home IS 'Номер дома';
 
ALTER TABLE public.r_expert ADD living_building varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN living_building SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.living_building IS 'Корпус/Строение';
 
ALTER TABLE public.r_expert ADD living_apartment_number varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN living_apartment_number SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.living_apartment_number IS 'Квартира/Офис';
 
ALTER TABLE public.r_expert ADD full_address text NULL;
ALTER TABLE public.r_expert ALTER COLUMN full_address SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.full_address IS 'Адрес одной строкой';
 
ALTER TABLE public.r_expert ADD education text NULL;
ALTER TABLE public.r_expert ALTER COLUMN education SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.education IS 'Образование';
 
ALTER TABLE public.r_expert ADD certificate_number varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN certificate_number SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.certificate_number IS 'Номер удостоверения эксперта';
 
ALTER TABLE public.r_expert ADD certificate_date date NULL;
ALTER TABLE public.r_expert ALTER COLUMN certificate_date SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.certificate_date IS 'Дата выдачи удостоверения';
 
ALTER TABLE public.r_expert ADD stop_reason varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN stop_reason SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.stop_reason IS 'Причина приостановления деятельности';
 
ALTER TABLE public.r_expert ADD stop_basis varchar(255) NULL;
ALTER TABLE public.r_expert ALTER COLUMN stop_basis SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert.stop_basis IS 'Основание приостановления деятельности';
 
ALTER TABLE public.r_expert ADD certificate_expire_date date NULL;
ALTER TABLE public.r_expert ALTER COLUMN certificate_expire_date SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert.certificate_expire_date IS 'Дата окончания действия удостоверения';   
ALTER TABLE public.r_expert_specialization ADD id bigserial NOT NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN id SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert_specialization.id IS 'Идентификатор версии записи справочника';
 
ALTER TABLE public.r_expert_specialization ADD create_date timestamptz DEFAULT now() NOT NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN create_date SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert_specialization.create_date IS 'Дата создания';
 
ALTER TABLE public.r_expert_specialization ADD author_id varchar(100) NOT NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN author_id SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert_specialization.author_id IS 'Автор';
 
ALTER TABLE public.r_expert_specialization ADD date_from timestamptz NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN date_from SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert_specialization.date_from IS 'Версия записи действительна с';
 
ALTER TABLE public.r_expert_specialization ADD date_to timestamptz NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN date_to SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert_specialization.date_to IS 'Версия записи действительна по';
 
ALTER TABLE public.r_expert_specialization ADD active bool DEFAULT true NOT NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN active SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert_specialization.active IS 'Версия записи актуальна';
 
ALTER TABLE public.r_expert_specialization ADD "uuid" uuid NOT NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN "uuid" SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert_specialization."uuid" IS 'Уникальный идентификатор записи справочника';
 
ALTER TABLE public.r_expert_specialization ADD expert_id int8 NOT NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN expert_id SET STORAGE PLAIN;
 
ALTER TABLE public.r_expert_specialization ADD attestation_order varchar(255) NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN attestation_order SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert_specialization.attestation_order IS 'Приказ об аттестации';
 
ALTER TABLE public.r_expert_specialization ADD attestation_expire_date date NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN attestation_expire_date SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert_specialization.attestation_expire_date IS 'Срок действия';
 
ALTER TABLE public.r_expert_specialization ADD attestation_date date NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN attestation_date SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert_specialization.attestation_date IS 'Дата аттестации';
 
ALTER TABLE public.r_expert_specialization ADD details text NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN details SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert_specialization.details IS 'Детализация';
 
ALTER TABLE public.r_expert_specialization ADD object_category text DEFAULT 'painting'::text NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN object_category SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert_specialization.object_category IS 'Категория культурной ценности (Приказ № 780)';
 
ALTER TABLE public.r_expert_specialization ADD item_order int8 NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN item_order SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert_specialization.item_order IS 'Порядковый номер';
 
ALTER TABLE public.r_expert_specialization ADD specialization_date date NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN specialization_date SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert_specialization.specialization_date IS 'Дата начала действия специализации';
 
ALTER TABLE public.r_expert_specialization ADD specialization_expire_date date NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN specialization_expire_date SET STORAGE PLAIN;
COMMENT ON COLUMN public.r_expert_specialization.specialization_expire_date IS 'Дата окончания действия специализации';
 
ALTER TABLE public.r_expert_specialization ADD region varchar(255) NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN region SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert_specialization.region IS 'Регион';
 
ALTER TABLE public.r_expert_specialization ADD detail_start_period text DEFAULT 'i'::text NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN detail_start_period SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert_specialization.detail_start_period IS 'Период от';
 
ALTER TABLE public.r_expert_specialization ADD detail_end_period text DEFAULT 'ii'::text NULL;
ALTER TABLE public.r_expert_specialization ALTER COLUMN detail_end_period SET STORAGE EXTENDED;
COMMENT ON COLUMN public.r_expert_specialization.detail_end_period IS 'Период до';
