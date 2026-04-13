-- Tạo bảng Sinh viên
CREATE TABLE STUDENT (
    StudentID NUMBER(8,0) CONSTRAINT student_id_pk PRIMARY KEY,
    Salutation VARCHAR2(5),
    FirstName VARCHAR2(25),
    LastName VARCHAR2(25) NOT NULL,
    Address VARCHAR2(50),
    Phone VARCHAR2(15),
    Employer VARCHAR2(50),
    RegistrationDate DATE NOT NULL,
    CreatedBy VARCHAR2(30) NOT NULL,
    CreatedDate DATE NOT NULL,
    ModifiedBy VARCHAR2(30) NOT NULL,
    ModifiedDate DATE NOT NULL
);

-- Tạo bảng Giáo viên
CREATE TABLE INSTRUCTOR (
    InstructorID NUMBER(8,0) CONSTRAINT instructor_id_pk PRIMARY KEY,
    Salutation VARCHAR2(5),
    FirstName VARCHAR2(25),
    LastName VARCHAR2(25),
    Address VARCHAR2(50),
    Phone VARCHAR2(15),
    CreatedBy VARCHAR2(30) NOT NULL,
    CreatedDate DATE NOT NULL,
    ModifiedBy VARCHAR2(30) NOT NULL,
    ModifiedDate DATE NOT NULL
);

-- Tạo bảng Môn học (Có tự tham chiếu môn học tiên quyết)
CREATE TABLE COURSE (
    CourseNo NUMBER(8,0) CONSTRAINT course_no_pk PRIMARY KEY,
    Description VARCHAR2(50),
    Cost NUMBER(9,2),
    Prerequisite NUMBER(8,0),
    CreatedBy VARCHAR2(30) NOT NULL,
    CreatedDate DATE NOT NULL,
    ModifiedBy VARCHAR2(30) NOT NULL,
    ModifiedDate DATE NOT NULL,
    CONSTRAINT course_prereq_fk FOREIGN KEY (Prerequisite) REFERENCES COURSE(CourseNo)
);

-- Tạo bảng Lớp học
CREATE TABLE CLASS (
    ClassID NUMBER(8,0) CONSTRAINT class_id_pk PRIMARY KEY,
    CourseNo NUMBER(8,0) NOT NULL,
    ClassNo NUMBER(3,0) NOT NULL,
    StartDateTime DATE,
    Location VARCHAR2(50),
    InstructorID NUMBER(8,0) NOT NULL,
    Capacity NUMBER(3,0),
    CreatedBy VARCHAR2(30) NOT NULL,
    CreatedDate DATE NOT NULL,
    ModifiedBy VARCHAR2(30) NOT NULL,
    ModifiedDate DATE NOT NULL,
    CONSTRAINT class_course_fk FOREIGN KEY (CourseNo) REFERENCES COURSE(CourseNo),
    CONSTRAINT class_inst_fk FOREIGN KEY (InstructorID) REFERENCES INSTRUCTOR(InstructorID)
);

-- Tạo bảng Đăng ký môn học
CREATE TABLE ENROLLMENT (
    StudentID NUMBER(8,0) NOT NULL,
    ClassID NUMBER(8,0) NOT NULL,
    EnrollDate DATE NOT NULL,
    FinalGrade NUMBER(3,0),
    CreatedBy VARCHAR2(30) NOT NULL,
    CreatedDate DATE NOT NULL,
    ModifiedBy VARCHAR2(30) NOT NULL,
    ModifiedDate DATE NOT NULL,
    CONSTRAINT enroll_pk PRIMARY KEY (StudentID, ClassID),
    CONSTRAINT enroll_stud_fk FOREIGN KEY (StudentID) REFERENCES STUDENT(StudentID),
    CONSTRAINT enroll_class_fk FOREIGN KEY (ClassID) REFERENCES CLASS(ClassID)
);

-- Tạo bảng Điểm số
CREATE TABLE GRADE (
    StudentID NUMBER(8,0) NOT NULL,
    ClassID NUMBER(8,0) NOT NULL,
    Grade NUMBER(3,0) NOT NULL,
    Comments VARCHAR2(2000),
    CreatedBy VARCHAR2(30) NOT NULL,
    CreatedDate DATE NOT NULL,
    ModifiedBy VARCHAR2(30) NOT NULL,
    ModifiedDate DATE NOT NULL,
    CONSTRAINT grade_stud_fk FOREIGN KEY (StudentID) REFERENCES STUDENT(StudentID),
    CONSTRAINT grade_class_fk FOREIGN KEY (ClassID) REFERENCES CLASS(ClassID)
);

-- 1. Chèn Giáo viên
INSERT INTO INSTRUCTOR (InstructorID, FirstName, LastName, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate) 
VALUES (1, 'Son', 'Tay', USER, SYSDATE, USER, SYSDATE);

-- 2. Chèn Môn học
INSERT INTO COURSE (CourseNo, Description, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate) 
VALUES (101, 'Java Backend', USER, SYSDATE, USER, SYSDATE);

-- 3. Chèn Lớp học
INSERT INTO CLASS (ClassID, CourseNo, ClassNo, InstructorID, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate) 
VALUES (10, 101, 1, 1, USER, SYSDATE, USER, SYSDATE);

-- 4. Chèn Sinh viên
INSERT INTO STUDENT (StudentID, FirstName, LastName, RegistrationDate, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate) 
VALUES (1001, 'Nguyen', 'An', SYSDATE, USER, SYSDATE, USER, SYSDATE);

-- 5. Chèn Đăng ký (Enrollment) - Cái này cực quan trọng để câu SELECT của ông có data
INSERT INTO ENROLLMENT (StudentID, ClassID, EnrollDate, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate) 
VALUES (1001, 10, SYSDATE, USER, SYSDATE, USER, SYSDATE);

COMMIT;

-- Chèn một con điểm 85 (Loại B) cho sinh viên 1001 ở lớp 10
INSERT INTO GRADE (StudentID, ClassID, Grade, Comments, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate) 
VALUES (1001, 10, 85, 'Làm bài khá tốt, cần phát huy!', USER, SYSDATE, USER, SYSDATE);

COMMIT;

-- script tổng hợp 
-- a. Tạo bảng Cau1
CREATE TABLE Cau1 (
    ID NUMBER,
    NAME VARCHAR2(50) 
);
SELECT c1.ID, c1.NAME FROM Cau1 c1;

-- b. Tạo sequence Cau1Seq
CREATE SEQUENCE Cau1Seq START WITH 1 INCREMENT BY 5;

-- c -> j: Khối lệnh PL/SQL xử lý logic
DECLARE
    v_name STUDENT.LastName%TYPE;
    v_id   NUMBER;
    v_temp_id NUMBER; 
BEGIN
    SELECT (FirstName || ' ' || LastName) INTO v_name
    FROM (SELECT s.FirstName, s.LastName FROM STUDENT s JOIN ENROLLMENT e ON s.StudentID = e.StudentID 
          GROUP BY s.StudentID, s.FirstName, s.LastName ORDER BY COUNT(*) DESC)
    WHERE ROWNUM = 1;
    
    INSERT INTO Cau1 VALUES (Cau1Seq.NEXTVAL, v_name);
    SAVEPOINT A;

    SELECT (FirstName || ' ' || LastName) INTO v_name
    FROM (SELECT s.FirstName, s.LastName FROM STUDENT s JOIN ENROLLMENT e ON s.StudentID = e.StudentID 
          GROUP BY s.StudentID, s.FirstName, s.LastName ORDER BY COUNT(*) ASC)
    WHERE ROWNUM = 1;
    
    INSERT INTO Cau1 VALUES (Cau1Seq.NEXTVAL, v_name);
    SAVEPOINT B;

    SELECT (FirstName || ' ' || LastName) INTO v_name
    FROM (SELECT i.FirstName, i.LastName FROM INSTRUCTOR i JOIN CLASS c ON i.InstructorID = c.InstructorID
          GROUP BY i.InstructorID, i.FirstName, i.LastName ORDER BY COUNT(*) DESC)
    WHERE ROWNUM = 1;
    
    INSERT INTO Cau1 VALUES (Cau1Seq.NEXTVAL, v_name);
    SAVEPOINT C;

    SELECT ID INTO v_id FROM Cau1 WHERE NAME = v_name AND ROWNUM = 1;
    v_temp_id := v_id; 

    ROLLBACK TO B;

    SELECT (FirstName || ' ' || LastName) INTO v_name
    FROM (SELECT i.FirstName, i.LastName FROM INSTRUCTOR i JOIN CLASS c ON i.InstructorID = c.InstructorID
          GROUP BY i.InstructorID, i.FirstName, i.LastName ORDER BY COUNT(*) ASC)
    WHERE ROWNUM = 1;
    
    INSERT INTO Cau1 VALUES (v_temp_id, v_name);

    SELECT (FirstName || ' ' || LastName) INTO v_name
    FROM (SELECT i.FirstName, i.LastName FROM INSTRUCTOR i JOIN CLASS c ON i.InstructorID = c.InstructorID
          GROUP BY i.InstructorID, i.FirstName, i.LastName ORDER BY COUNT(*) DESC)
    WHERE ROWNUM = 1;
    
    INSERT INTO Cau1 VALUES (Cau1Seq.NEXTVAL, v_name);
    
    COMMIT;
END;

/

SELECT USER, Cau1.* FROM Cau1;
-- câu 2: nhập mã sinh viên và xử lý thông tin 
DECLARE
    v_sid STUDENT.StudentID%TYPE := :Nhap_Ma_SV;
    v_fname STUDENT.FirstName%TYPE;
    v_lname STUDENT.LastName%TYPE;
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM STUDENT WHERE StudentID = v_sid;
    
    IF v_count > 0 THEN
        SELECT FirstName, LastName INTO v_fname, v_lname FROM STUDENT WHERE StudentID = v_sid;
        SELECT COUNT(*) INTO v_count FROM ENROLLMENT WHERE StudentID = v_sid;
        DBMS_OUTPUT.PUT_LINE('Họ tên: ' || v_fname || ' ' || v_lname || ' - Số lớp đang học: ' || v_count);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Sinh viên không tồn tại. Đang tạo mới...');
        INSERT INTO STUDENT (StudentID, FirstName, LastName, Address, RegistrationDate, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate)
        VALUES (v_sid, '&Nhap_Ten', '&Nhap_Ho', '&Nhap_Dia_Chi', SYSDATE, USER, SYSDATE, USER, SYSDATE);
        COMMIT;
    END IF;
END;

/

-- TEST CÂU 2:
-- Chạy script, nhập ID 101 (đã có) và ID 999 (chưa có) để kiểm tra.

-- bài 2 
-- câu 1 
DECLARE
    v_inst_id INSTRUCTOR.InstructorID%TYPE := :Nhap_Ma_GV;
    v_class_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_class_count FROM CLASS WHERE InstructorID = v_inst_id;
    
    IF v_class_count >= 5 THEN
        DBMS_OUTPUT.PUT_LINE('Giáo viên này nên nghỉ ngơi!');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Số lớp đang dạy: ' || v_class_count);
    END IF;
END;
/

-- TEST BÀI 2.1:
-- Nhập mã GV có nhiều lớp dạy (trong dữ liệu mẫu) để xem thông báo.
-- câu 2
DECLARE
    v_sid STUDENT.StudentID%TYPE := :Ma_SV;
    v_cid CLASS.ClassID%TYPE := :Ma_Lop;
    v_grade GRADE.Grade%TYPE;
    v_exists_s NUMBER;
    v_exists_c NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_exists_s FROM STUDENT WHERE StudentID = v_sid;
    SELECT COUNT(*) INTO v_exists_c FROM CLASS WHERE ClassID = v_cid;
    
    IF v_exists_s = 0 THEN 
        DBMS_OUTPUT.PUT_LINE('Lỗi: Mã sinh viên ' || v_sid || ' không tồn tại.');
    ELSIF v_exists_c = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Lỗi: Mã lớp ' || v_cid || ' không tồn tại.');
    ELSE
        SELECT Grade INTO v_grade FROM GRADE WHERE StudentID = v_sid AND ClassID = v_cid;
        CASE 
            WHEN v_grade >= 90 THEN DBMS_OUTPUT.PUT_LINE('Điểm: A');
            WHEN v_grade >= 80 THEN DBMS_OUTPUT.PUT_LINE('Điểm: B');
            WHEN v_grade >= 70 THEN DBMS_OUTPUT.PUT_LINE('Điểm: C');
            WHEN v_grade >= 50 THEN DBMS_OUTPUT.PUT_LINE('Điểm: D');
            ELSE DBMS_OUTPUT.PUT_LINE('Điểm: F');
        END CASE;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Sinh viên chưa có điểm trong lớp này.');
END;
/

-- TEST BÀI 2.2:
-- Nhập mã SV: 101, mã lớp: 10 (có điểm) -> Check kết quả.

-- bài 3 
DECLARE
    CURSOR cur_course IS 
        SELECT CourseNo, Description FROM COURSE;
        
    CURSOR cur_class(p_cno NUMBER) IS 
        SELECT c.ClassID, COUNT(e.StudentID) as total_std
        FROM CLASS c 
        LEFT JOIN ENROLLMENT e ON c.ClassID = e.ClassID
        WHERE c.CourseNo = p_cno
        GROUP BY c.ClassID; 
BEGIN
    DBMS_OUTPUT.PUT_LINE('User: ' || USER);
    
    FOR r_course IN cur_course LOOP
        DBMS_OUTPUT.PUT_LINE(r_course.CourseNo || ' ' || r_course.Description);
        
        FOR r_class IN cur_class(r_course.CourseNo) LOOP
            DBMS_OUTPUT.PUT_LINE('  Lop: ' || r_class.ClassID || ' co so luong sinh vien dang ki: ' || r_class.total_std);
        END LOOP;
    END LOOP;
END;

/

-- TEST BÀI 3:
-- Xem Output hiển thị đúng định dạng phân cấp Môn học -> Lớp học.

-- bài 4 
-- a. Thủ tục tìm tên
CREATE OR REPLACE PROCEDURE find_sname (
    i_student_id IN NUMBER,
    o_first_name OUT VARCHAR2,
    o_last_name OUT VARCHAR2
) AS
BEGIN
    SELECT FirstName, LastName INTO o_first_name, o_last_name FROM STUDENT WHERE StudentID = i_student_id;
END;
/

-- b. Thủ tục in tên
CREATE OR REPLACE PROCEDURE print_student_name (i_student_id IN NUMBER) AS
    v_f VARCHAR2(50);
    v_l VARCHAR2(50);
BEGIN
    find_sname(i_student_id, v_f, v_l);
    DBMS_OUTPUT.PUT_LINE('Tên sinh viên: ' || v_f || ' ' || v_l);
EXCEPTION
    WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Không tìm thấy SV mã ' || i_student_id);
END;
/

BEGIN
	print_student_name(1001);
END;
-- thủ tục discount 
CREATE OR REPLACE PROCEDURE Discount AS
BEGIN
    FOR r IN (SELECT CourseNo, Description FROM COURSE 
              WHERE CourseNo IN (SELECT c.CourseNo FROM CLASS c JOIN ENROLLMENT e ON c.ClassID = e.ClassID 
                                 GROUP BY c.CourseNo HAVING COUNT(*) > 15)) LOOP
        UPDATE COURSE SET Cost = Cost * 0.95 WHERE CourseNo = r.CourseNo;
        DBMS_OUTPUT.PUT_LINE('Giảm giá cho môn: ' || r.Description);
    END LOOP;
END;
/

BEGIN
	Discount;
END;
-- hàm tính tổng chi phí 
CREATE OR REPLACE FUNCTION Total_cost_for_student (i_sid IN NUMBER) RETURN NUMBER AS
    v_total NUMBER;
    v_exists NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM STUDENT WHERE StudentID = i_sid;
    IF v_exists = 0 THEN RETURN NULL; END IF;
    
    SELECT SUM(c.Cost) INTO v_total
    FROM ENROLLMENT e JOIN CLASS cl ON e.ClassID = cl.ClassID JOIN COURSE c ON cl.CourseNo = c.CourseNo
    WHERE e.StudentID = i_sid;
    
    RETURN NVL(v_total, 0);
END;
/

SELECT Total_cost_for_student(1001) FROM DUAL;
-- bài 5 trigger 
-- Ví dụ cho bảng COURSE, ông có thể tạo tương tự cho các bảng khác
CREATE OR REPLACE TRIGGER trg_audit_course
BEFORE INSERT OR UPDATE ON COURSE
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :NEW.CreatedBy := USER;
        :NEW.CreatedDate := SYSDATE;
    END IF;
    :NEW.ModifiedBy := USER;
    :NEW.ModifiedDate := SYSDATE;
END;
/

INSERT INTO COURSE (CourseNo, Description, Cost) VALUES (999, 'Test Trigger', 500);
SELECT CreatedBy, CreatedDate FROM COURSE WHERE CourseNo = 999;
-- giới hạn 3 môn học cho sinh viên
CREATE OR REPLACE TRIGGER trg_limit_enrollment
BEFORE INSERT ON ENROLLMENT
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM ENROLLMENT WHERE StudentID = :NEW.StudentID;
    IF v_count >= 3 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Mỗi sinh viên không được đăng ký quá 3 môn học!');
    END IF;
END;
/

INSERT INTO CLASS (ClassID, CourseNo, ClassNo, InstructorID, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate) 
VALUES (20, 101, 2, 1, USER, SYSDATE, USER, SYSDATE);

INSERT INTO CLASS (ClassID, CourseNo, ClassNo, InstructorID, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate) 
VALUES (30, 101, 3, 1, USER, SYSDATE, USER, SYSDATE);

INSERT INTO CLASS (ClassID, CourseNo, ClassNo, InstructorID, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate) 
VALUES (40, 101, 4, 1, USER, SYSDATE, USER, SYSDATE);

COMMIT;


-- Đăng ký lớp thứ 2 (Sẽ thành công - Tổng cộng là 2)
INSERT INTO ENROLLMENT (StudentID, ClassID, EnrollDate, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate) 
VALUES (1001, 20, SYSDATE, USER, SYSDATE, USER, SYSDATE);

-- Đăng ký lớp thứ 3 (Sẽ thành công - Đây là giới hạn cuối cùng)
INSERT INTO ENROLLMENT (StudentID, ClassID, EnrollDate, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate) 
VALUES (1001, 30, SYSDATE, USER, SYSDATE, USER, SYSDATE);

-- Đăng ký lớp thứ 4 (TRIGGER SẼ CHẶN LẠI VÀ BÁO LỖI ORA-20001)
INSERT INTO ENROLLMENT (StudentID, ClassID, EnrollDate, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate) 
VALUES (1001, 40, SYSDATE, USER, SYSDATE, USER, SYSDATE);

-- TEST BÀI 5.2:
-- Thử chèn dòng thứ 4 cho cùng 1 StudentID -> Sẽ báo lỗi.

