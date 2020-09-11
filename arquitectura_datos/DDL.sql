/*PASO1*/
CREATE USER universitydbuserlive with login ENCRYPTED PASSWORD ?;
/*PASO 2*/
CREATE TABLESPACE uan_rmdbs_workshoplive_ts
  OWNER postgres
  LOCATION ?;
ALTER TABLESPACE uan_rmdbs_workshoplive_ts
  OWNER TO universitydbuserlive;

/*PASO 3*/

CREATE DATABASE uan_university_live_db
    WITH
    OWNER = universitydbuserlive
    ENCODING = 'UTF8'
    TABLESPACE = uan_rmdbs_workshoplive_ts
    CONNECTION LIMIT = -1;

/*PASO 4*/

CREATE SCHEMA courses AUTHORIZATION universitydbuserlive;
CREATE SCHEMA courses_app AUTHORIZATION universitydbuserlive;

/*PASO 5.1*/

SET search_path = courses;

DROP TABLE IF EXISTS prereq;
DROP TABLE IF EXISTS time_slot;
DROP TABLE IF EXISTS advisor;
DROP TABLE IF EXISTS takes;
DROP TABLE IF EXISTS student;
DROP TABLE IF EXISTS teaches;
DROP TABLE IF EXISTS section;
DROP TABLE IF EXISTS instructor;
DROP TABLE IF EXISTS course;
DROP TABLE IF EXISTS department;
DROP TABLE IF EXISTS classroom;



SET search_path = courses_app;

DROP TABLE IF EXISTS prereq;
DROP TABLE IF EXISTS time_slot;
DROP TABLE IF EXISTS advisor;
DROP TABLE IF EXISTS takes;
DROP TABLE IF EXISTS student;
DROP TABLE IF EXISTS teaches;
DROP TABLE IF EXISTS section;
DROP TABLE IF EXISTS instructor;
DROP TABLE IF EXISTS course;
DROP TABLE IF EXISTS department;
DROP TABLE IF EXISTS classroom;


/*PASO 5.1 CREATE TABLES*/

SET search_path = courses;
CREATE TABLE classroom
(
    building    varchar(15),
    room_number varchar(7),
    capacity    numeric(4, 0),
    PRIMARY KEY (building, room_number)
);

CREATE TABLE department
(
    dept_name varchar(20),
    building  varchar(15),
    budget    numeric(12, 2) CHECK (budget > 0),
    PRIMARY KEY (dept_name)
);

CREATE TABLE course
(
    course_id varchar(8),
    title     varchar(50),
    dept_name varchar(20),
    credits   numeric(2, 0) CHECK (credits > 0),
    PRIMARY KEY (course_id),
    FOREIGN KEY (dept_name) REFERENCES department (dept_name)
        ON DELETE SET null
);

CREATE TABLE instructor
(
    instructor_id        varchar(5),
    name      varchar(20) not null,
    dept_name varchar(20),
    salary    numeric(8, 2) CHECK (salary > 29000),
    PRIMARY KEY (instructor_id),
    FOREIGN KEY (dept_name) REFERENCES department (dept_name)
        ON DELETE SET null
);

CREATE TABLE section
(
    course_id    varchar(8),
    section_id       varchar(8),
    semester     varchar(6)
        CHECK (semester in ('Fall', 'Winter', 'Spring', 'Summer')),
    year         numeric(4, 0) CHECK (year > 1701 and year < 2100),
    building     varchar(15),
    room_number  varchar(7),
    time_slot_id varchar(4),
    PRIMARY KEY (course_id, section_id, semester, year),
    FOREIGN KEY (course_id) REFERENCES course (course_id)
        ON DELETE CASCADE,
    FOREIGN KEY (building, room_number) REFERENCES classroom (building, room_number)
        ON DELETE SET null
);

CREATE TABLE teaches
(
    teaches_id varchar(5),
    course_id varchar(8),
    section_id    varchar(8),
    semester  varchar(6),
    year      numeric(4, 0),
    PRIMARY KEY (teaches_id, course_id, section_id, semester, year),
    FOREIGN KEY (course_id, section_id, semester, year) REFERENCES section (course_id, section_id, semester, year)
        ON DELETE CASCADE,
    FOREIGN KEY (teaches_id) REFERENCES instructor (instructor_id)
        ON DELETE CASCADE
);

CREATE TABLE student
(
    student_id        varchar(5),
    name      varchar(20) not null,
    dept_name varchar(20),
    tot_cred  numeric(3, 0) CHECK (tot_cred >= 0),
    PRIMARY KEY (student_id),
    FOREIGN KEY (dept_name) REFERENCES department (dept_name)
        ON DELETE SET null
);

CREATE TABLE takes
(
    takes_id        varchar(5),
    course_id varchar(8),
    section_id    varchar(8),
    semester  varchar(6),
    year      numeric(4, 0),
    grade     varchar(2),
    PRIMARY KEY (takes_id, course_id, section_id, semester, year),
    FOREIGN KEY (course_id, section_id, semester, year) REFERENCES section (course_id, section_id, semester, year)
        ON DELETE CASCADE,
    FOREIGN KEY (takes_id) REFERENCES student (student_id)
        ON DELETE CASCADE
);

CREATE TABLE advisor
(
    student_id varchar(5),
    instructor_id varchar(5),
    PRIMARY KEY (student_id),
    FOREIGN KEY (instructor_id) REFERENCES instructor (instructor_id)
        ON DELETE SET null,
    FOREIGN KEY (student_id) REFERENCES student (student_id)
        ON DELETE CASCADE
);

CREATE TABLE time_slot
(
    time_slot_id varchar(4),
    day          varchar(1),
    start_hr     numeric(2) CHECK (start_hr >= 0 and start_hr < 24),
    start_min    numeric(2) CHECK (start_min >= 0 and start_min < 60),
    end_hr       numeric(2) CHECK (end_hr >= 0 and end_hr < 24),
    end_min      numeric(2) CHECK (end_min >= 0 and end_min < 60),
    PRIMARY KEY (time_slot_id, day, start_hr, start_min),
    UNIQUE (time_slot_id)
);

CREATE TABLE prereq
(
    course_id varchar(8),
    prereq_id varchar(8),
    PRIMARY KEY (course_id, prereq_id),
    FOREIGN KEY (course_id) REFERENCES course (course_id)
        ON DELETE CASCADE,
    FOREIGN KEY (prereq_id) REFERENCES course (course_id)
);
/*PASO 5.1 CREATE TABLES//////////5-createTablesForApps*/

SET search_path = courses_app;
CREATE TABLE classroom
(
    classroom_id integer PRIMARY KEY,
    building     varchar(15),
    room_number  varchar(7),
    capacity     numeric(4, 0),
    UNIQUE (building, room_number),
    CHECK (classroom_id > 0)
);

CREATE TABLE department
(
    dept_id   integer PRIMARY KEY,
    dept_name varchar(20),
    building  varchar(15),
    budget    numeric(12, 2) CHECK (budget > 0),
    UNIQUE (dept_name),
    CHECK (dept_id > 0)
);

CREATE TABLE course
(
    course_id integer PRIMARY KEY,
    title     varchar(50),
    dept_id   integer,
    credits   numeric(2, 0) CHECK (credits > 0),
    FOREIGN KEY (dept_id) REFERENCES department (dept_id)
        ON DELETE SET null,
    CHECK (course_id > 0)
);

CREATE TABLE instructor
(
    instructor_id integer PRIMARY KEY,
    name          varchar(20) not null,
    dept_id       integer,
    salary        numeric(8, 2) CHECK (salary > 29000),
    FOREIGN KEY (dept_id) REFERENCES department (dept_id)
        ON DELETE SET null,
    CHECK (instructor_id > 0)
);

CREATE TABLE section
(
    section_id   integer PRIMARY KEY,
    course_id    integer,
    classroom_id integer,
    semester     varchar(6)
        CHECK (semester in ('Fall', 'Winter', 'Spring', 'Summer')),
    year         numeric(4, 0) CHECK (year > 1701 and year < 2100),
    time_slot_id integer,
    UNIQUE (course_id, section_id, semester, year),
    FOREIGN KEY (course_id) REFERENCES course (course_id)
        ON DELETE CASCADE,
    FOREIGN KEY (classroom_id) REFERENCES classroom (classroom_id)
        ON DELETE SET null,
    CHECK (section_id > 0)
);

CREATE TABLE teaches
(
    teaches_id integer PRIMARY KEY,
    course_id  integer,
    section_id integer,
    FOREIGN KEY (section_id) REFERENCES section (section_id)
        ON DELETE CASCADE,
    FOREIGN KEY (teaches_id) REFERENCES instructor (instructor_id)
        ON DELETE CASCADE,
    UNIQUE (course_id, section_id),
    CHECK (teaches_id > 0)
);

CREATE TABLE student
(
    student_id integer PRIMARY KEY,
    name       varchar(20) not null,
    dept_id  integer,
    tot_cred   numeric(3, 0) CHECK (tot_cred >= 0),
    FOREIGN KEY (dept_id) REFERENCES department (dept_id)
        ON DELETE SET null,
    CHECK (student_id > 0)
);

CREATE TABLE takes
(
    takes_id   integer PRIMARY KEY,
    course_id  integer,
    section_id integer,
    grade      varchar(2),
    UNIQUE (course_id, section_id),
    FOREIGN KEY (section_id) REFERENCES section (section_id)
        ON DELETE CASCADE,
    FOREIGN KEY (takes_id) REFERENCES student (student_id)
        ON DELETE CASCADE,
    CHECK (takes_id > 0)
);

CREATE TABLE advisor
(
    student_id integer PRIMARY KEY,
    instructor_id integer,
    FOREIGN KEY (instructor_id) REFERENCES instructor (instructor_id)
        ON DELETE SET null,
    FOREIGN KEY (student_id) REFERENCES student (student_id)
        ON DELETE CASCADE,
    CHECK (student_id > 0)
);

CREATE TABLE time_slot
(
    time_slot_id integer PRIMARY KEY,
    time_slot_name varchar(4),
    day          varchar(1),
    start_hr     numeric(2) CHECK (start_hr >= 0 and start_hr < 24),
    start_min    numeric(2) CHECK (start_min >= 0 and start_min < 60),
    end_hr       numeric(2) CHECK (end_hr >= 0 and end_hr < 24),
    end_min      numeric(2) CHECK (end_min >= 0 and end_min < 60),
    UNIQUE (time_slot_name, day, start_hr, start_min),
    CHECK (time_slot_id > 0)
);

CREATE TABLE prereq
(
    prereq_id integer PRIMARY KEY,
    prereq_course_id integer,
    course_id integer,
    UNIQUE (prereq_course_id, course_id),
    FOREIGN KEY (prereq_course_id) REFERENCES course (course_id)
        ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES course (course_id),
    CHECK (prereq_id > 0)
);

/*6-addMissingReferenceTimeSlot*/
/*****no funciono*****/
SET search_path = courses;
ALTER TABLE section ADD FOREIGN KEY(time_slot_id) REFERENCES time_slot (time_slot_id);

/*6-6-addMissingReferenceTimeSlotApp*/
SET search_path = courses_app;
ALTER TABLE section ADD FOREIGN KEY(time_slot_id) REFERENCES time_slot (time_slot_id);

CREATE USER universityappuserlive with login ENCRYPTED PASSWORD ?;