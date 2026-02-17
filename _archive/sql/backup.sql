--
-- PostgreSQL database dump
--

\restrict CAh3vF4nux6i1a66EQXxJ2MITTwb6HCpRt1tOhANmrt5LDEJKRax8hBAJonF25W

-- Dumped from database version 16.12 (Debian 16.12-1.pgdg13+1)
-- Dumped by pg_dump version 16.12 (Debian 16.12-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: classmate
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO classmate;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: classmate
--

COMMENT ON SCHEMA public IS '';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: Assignment; Type: TABLE; Schema: public; Owner: classmate
--

CREATE TABLE public."Assignment" (
    id text NOT NULL,
    "subjectId" text NOT NULL,
    title text NOT NULL,
    "dueAt" timestamp(3) without time zone,
    details text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "classroomId" text NOT NULL,
    "createdById" text NOT NULL,
    "schoolId" text NOT NULL
);


ALTER TABLE public."Assignment" OWNER TO classmate;

--
-- Name: AssignmentSubmission; Type: TABLE; Schema: public; Owner: classmate
--

CREATE TABLE public."AssignmentSubmission" (
    id text NOT NULL,
    "assignmentId" text NOT NULL,
    "userId" text NOT NULL,
    text text,
    "mediaUrl" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."AssignmentSubmission" OWNER TO classmate;

--
-- Name: AttendanceRecord; Type: TABLE; Schema: public; Owner: classmate
--

CREATE TABLE public."AttendanceRecord" (
    id text NOT NULL,
    "userId" text NOT NULL,
    "subjectId" text NOT NULL,
    date timestamp(3) without time zone NOT NULL,
    status text NOT NULL,
    teacher text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."AttendanceRecord" OWNER TO classmate;

--
-- Name: Classroom; Type: TABLE; Schema: public; Owner: classmate
--

CREATE TABLE public."Classroom" (
    id text NOT NULL,
    "schoolId" text NOT NULL,
    grade integer NOT NULL,
    "subjectId" text NOT NULL,
    title text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."Classroom" OWNER TO classmate;

--
-- Name: ClassroomMember; Type: TABLE; Schema: public; Owner: classmate
--

CREATE TABLE public."ClassroomMember" (
    id text NOT NULL,
    "classroomId" text NOT NULL,
    "userId" text NOT NULL,
    role text DEFAULT 'student'::text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."ClassroomMember" OWNER TO classmate;

--
-- Name: Grade; Type: TABLE; Schema: public; Owner: classmate
--

CREATE TABLE public."Grade" (
    id text NOT NULL,
    "userId" text NOT NULL,
    "subjectId" text NOT NULL,
    title text NOT NULL,
    score double precision NOT NULL,
    "maxScore" double precision DEFAULT 100 NOT NULL,
    date timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."Grade" OWNER TO classmate;

--
-- Name: GradeSubjectPack; Type: TABLE; Schema: public; Owner: classmate
--

CREATE TABLE public."GradeSubjectPack" (
    id text NOT NULL,
    grade integer NOT NULL,
    kind text NOT NULL,
    "subjectId" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "schoolId" text DEFAULT 'demo-school'::text NOT NULL
);


ALTER TABLE public."GradeSubjectPack" OWNER TO classmate;

--
-- Name: Major; Type: TABLE; Schema: public; Owner: classmate
--

CREATE TABLE public."Major" (
    id text NOT NULL,
    "schoolId" text DEFAULT 'demo-school'::text NOT NULL,
    name text NOT NULL,
    type text NOT NULL
);


ALTER TABLE public."Major" OWNER TO classmate;

--
-- Name: MajorSubject; Type: TABLE; Schema: public; Owner: classmate
--

CREATE TABLE public."MajorSubject" (
    id text NOT NULL,
    "schoolId" text DEFAULT 'demo-school'::text NOT NULL,
    "majorId" text NOT NULL,
    "subjectId" text NOT NULL
);


ALTER TABLE public."MajorSubject" OWNER TO classmate;

--
-- Name: Message; Type: TABLE; Schema: public; Owner: classmate
--

CREATE TABLE public."Message" (
    id text NOT NULL,
    "classroomId" text NOT NULL,
    "userId" text NOT NULL,
    kind text DEFAULT 'text'::text NOT NULL,
    text text,
    "mediaUrl" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."Message" OWNER TO classmate;

--
-- Name: Notification; Type: TABLE; Schema: public; Owner: classmate
--

CREATE TABLE public."Notification" (
    id text NOT NULL,
    "userId" text NOT NULL,
    kind text NOT NULL,
    title text NOT NULL,
    body text,
    "seenAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."Notification" OWNER TO classmate;

--
-- Name: Role; Type: TABLE; Schema: public; Owner: classmate
--

CREATE TABLE public."Role" (
    id text NOT NULL,
    name text NOT NULL
);


ALTER TABLE public."Role" OWNER TO classmate;

--
-- Name: ScheduleEntry; Type: TABLE; Schema: public; Owner: classmate
--

CREATE TABLE public."ScheduleEntry" (
    id text NOT NULL,
    "userId" text,
    "subjectId" text NOT NULL,
    "startAt" timestamp(3) without time zone NOT NULL,
    "endAt" timestamp(3) without time zone NOT NULL,
    room text,
    teacher text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "classroomId" text NOT NULL,
    "schoolId" text NOT NULL
);


ALTER TABLE public."ScheduleEntry" OWNER TO classmate;

--
-- Name: School; Type: TABLE; Schema: public; Owner: classmate
--

CREATE TABLE public."School" (
    id text NOT NULL,
    name text NOT NULL
);


ALTER TABLE public."School" OWNER TO classmate;

--
-- Name: Solution; Type: TABLE; Schema: public; Owner: classmate
--

CREATE TABLE public."Solution" (
    id text NOT NULL,
    "userId" text NOT NULL,
    "subjectId" text NOT NULL,
    grade integer NOT NULL,
    book text NOT NULL,
    page integer NOT NULL,
    question text NOT NULL,
    caption text,
    "mediaUrl" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "classroomId" text NOT NULL,
    "schoolId" text NOT NULL
);


ALTER TABLE public."Solution" OWNER TO classmate;

--
-- Name: SolutionComment; Type: TABLE; Schema: public; Owner: classmate
--

CREATE TABLE public."SolutionComment" (
    id text NOT NULL,
    "solutionId" text NOT NULL,
    "userId" text NOT NULL,
    text text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."SolutionComment" OWNER TO classmate;

--
-- Name: SolutionLike; Type: TABLE; Schema: public; Owner: classmate
--

CREATE TABLE public."SolutionLike" (
    id text NOT NULL,
    "solutionId" text NOT NULL,
    "userId" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."SolutionLike" OWNER TO classmate;

--
-- Name: StudentSubject; Type: TABLE; Schema: public; Owner: classmate
--

CREATE TABLE public."StudentSubject" (
    id text NOT NULL,
    "userId" text NOT NULL,
    "subjectId" text NOT NULL,
    source text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "schoolId" text DEFAULT 'demo-school'::text NOT NULL
);


ALTER TABLE public."StudentSubject" OWNER TO classmate;

--
-- Name: Subject; Type: TABLE; Schema: public; Owner: classmate
--

CREATE TABLE public."Subject" (
    id text NOT NULL,
    name text NOT NULL,
    "schoolId" text DEFAULT 'demo-school'::text NOT NULL
);


ALTER TABLE public."Subject" OWNER TO classmate;

--
-- Name: User; Type: TABLE; Schema: public; Owner: classmate
--

CREATE TABLE public."User" (
    id text NOT NULL,
    email text NOT NULL,
    "passwordHash" text NOT NULL,
    "fullName" text NOT NULL,
    username text NOT NULL,
    "nationalId" text,
    grade integer NOT NULL,
    "schoolId" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "scientificMajor" text,
    "technologicalMajor" text,
    "mathUnits" text,
    "englishUnits" text
);


ALTER TABLE public."User" OWNER TO classmate;

--
-- Name: UserRole; Type: TABLE; Schema: public; Owner: classmate
--

CREATE TABLE public."UserRole" (
    "userId" text NOT NULL,
    "roleId" text NOT NULL
);


ALTER TABLE public."UserRole" OWNER TO classmate;

--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: classmate
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public._prisma_migrations OWNER TO classmate;

--
-- Data for Name: Assignment; Type: TABLE DATA; Schema: public; Owner: classmate
--

COPY public."Assignment" (id, "subjectId", title, "dueAt", details, "createdAt", "classroomId", "createdById", "schoolId") FROM stdin;
cmlns6kgp0001mj013xn18zbe	ab43c67a-611e-42b6-b493-40defb03f823	Arabic HW #1	2026-02-20 18:00:00	Do questions 1-3	2026-02-15 13:28:16.922	cmlmr8htm000moo01lgtt7b8r	cmlmr8hte0001oo01xhbsm3r6	nazareth-baptist
cmlntw4do0005mj01fo4jvweq	ab43c67a-611e-42b6-b493-40defb03f823	Smoke HW	2026-02-20 18:00:00	smoke	2026-02-15 14:16:08.748	cmlmr8htm000moo01lgtt7b8r	cmlmr8hte0001oo01xhbsm3r6	nazareth-baptist
\.


--
-- Data for Name: AssignmentSubmission; Type: TABLE DATA; Schema: public; Owner: classmate
--

COPY public."AssignmentSubmission" (id, "assignmentId", "userId", text, "mediaUrl", "createdAt") FROM stdin;
cmlntom0c0003mj01i4fm8tng	cmlns6kgp0001mj013xn18zbe	cmlms1ao20003jv01zyhz4ej1	My answers: 1) ... 2) ... 3) ...	\N	2026-02-15 14:10:18.348
cmlntw4e20007mj01cterbuo6	cmlntw4do0005mj01fo4jvweq	cmlms1ao20003jv01zyhz4ej1	smoke submit	\N	2026-02-15 14:16:08.762
\.


--
-- Data for Name: AttendanceRecord; Type: TABLE DATA; Schema: public; Owner: classmate
--

COPY public."AttendanceRecord" (id, "userId", "subjectId", date, status, teacher, "createdAt") FROM stdin;
\.


--
-- Data for Name: Classroom; Type: TABLE DATA; Schema: public; Owner: classmate
--

COPY public."Classroom" (id, "schoolId", grade, "subjectId", title, "createdAt") FROM stdin;
cmlld20zj000csc01111ded4h	demo-school	10	sub_arabic	Arabic - Grade 10	2026-02-13 20:49:18.464
cmlld20zk000esc01gt4el84f	demo-school	10	sub_hebrew	Hebrew - Grade 10	2026-02-13 20:49:18.465
cmlld20zl000gsc01n5rr51bp	demo-school	10	sub_pe	PE - Grade 10	2026-02-13 20:49:18.465
cmlld20zl000isc01ncqsvacq	demo-school	10	sub_religion	Religion - Grade 10	2026-02-13 20:49:18.466
cmlld20zm000ksc01juv6brbk	demo-school	10	sub_chapel	Chapel - Grade 10	2026-02-13 20:49:18.466
cmlld20zm000msc01ys89brtj	demo-school	10	sub_english	English - Grade 10	2026-02-13 20:49:18.467
cmlld20zn000osc018yy57v3h	demo-school	10	sub_math	Math - Grade 10	2026-02-13 20:49:18.467
cmlld20zn000qsc019cx3lvsh	demo-school	10	sub_physics	Physics - Grade 10	2026-02-13 20:49:18.468
cmlld20zo000ssc01sr97p9wa	demo-school	10	sub_computer_science	Computer Science - Grade 10	2026-02-13 20:49:18.468
cmlmfzbnc000wpf01qx16xwsy	demo-school	7	sub_arabic	Arabic - Grade 7	2026-02-14 14:58:57.336
cmlmfzbnd000ypf01ef81npwo	demo-school	7	sub_hebrew	Hebrew - Grade 7	2026-02-14 14:58:57.337
cmlmfzbne0010pf01e29c13eo	demo-school	7	sub_pe	PE - Grade 7	2026-02-14 14:58:57.338
cmlmfzbne0012pf01w3gco9cc	demo-school	7	sub_religion	Religion - Grade 7	2026-02-14 14:58:57.339
cmlmfzbnf0014pf012daz2n1i	demo-school	7	sub_chapel	Chapel - Grade 7	2026-02-14 14:58:57.339
cmlmfzbng0016pf01n74bw8am	demo-school	7	sub_math	Math - Grade 7	2026-02-14 14:58:57.34
cmlmfzbng0018pf01rs4lgkj1	demo-school	7	sub_chemistry	Chemistry - Grade 7	2026-02-14 14:58:57.341
cmlmfzbnh001apf01ocpcdh3a	demo-school	7	sub_biology	Biology - Grade 7	2026-02-14 14:58:57.341
cmlmfzbnh001cpf01ir6fz4cq	demo-school	7	sub_electronics	Electronics - Grade 7	2026-02-14 14:58:57.342
cmlmi956u004gpf01ri1ok854	demo-school	10	sub_chemistry	Chemistry - Grade 10	2026-02-14 16:02:34.758
cmlmi956v004ipf011g01fnpb	demo-school	10	sub_electronics	Electronics - Grade 10	2026-02-14 16:02:34.759
cmlmq65h3000eqj014cixuhz0	demo-school	10	13e66761-da74-4866-88e5-7d2fa588dc87	Education - Grade 10	2026-02-14 19:44:12.087
cmlmq65h4000gqj01vdpm137c	demo-school	10	052a07e9-7224-4531-b063-f841e349036c	History - Grade 10	2026-02-14 19:44:12.088
cmlmq65h4000iqj015vm752gl	demo-school	10	d3db3f9d-2269-4d5e-9ac5-5461d27d4531	Driving Theory - Grade 10	2026-02-14 19:44:12.089
cmlmqix4i0018qj01b3a4anjo	nazareth-baptist	10	84a2cd40-c8a1-4cef-a0f8-2bfdb568d2ea	Hebrew - Grade 10	2026-02-14 19:54:07.794
cmlmqix4i001aqj01of345zha	nazareth-baptist	10	bba3b58c-9184-4d7a-a9ff-ac6e08ff38b9	PE - Grade 10	2026-02-14 19:54:07.795
cmlmqix4j001cqj01l1gocyxw	nazareth-baptist	10	5d777c2f-79dd-4675-af7a-62f6c7049fe1	Religion - Grade 10	2026-02-14 19:54:07.796
cmlmqix4k001eqj01ojw3z9xg	nazareth-baptist	10	878c91ad-7133-4ed4-8579-384a44490f76	Chapel - Grade 10	2026-02-14 19:54:07.796
cmlmqix4k001gqj01td1fqbkv	nazareth-baptist	10	d99bd5ee-8e30-406a-99d1-97f6eb23d5e6	Math - Grade 10	2026-02-14 19:54:07.797
cmlmqix4l001iqj01uvkwp585	nazareth-baptist	10	ab43c67a-611e-42b6-b493-40defb03f823	Arabic - Grade 10	2026-02-14 19:54:07.797
cmlmqix4l001kqj01hd2i4ioe	nazareth-baptist	10	79c96f2b-1b2b-4862-b069-782f84533050	English - Grade 10	2026-02-14 19:54:07.798
cmlmqix4m001mqj01u9n67o52	nazareth-baptist	10	2f445af3-684e-4bda-b5bf-8777d694bff7	Education - Grade 10	2026-02-14 19:54:07.798
cmlmqix4m001oqj01u6crj0u4	nazareth-baptist	10	5b074a0d-2616-45d7-979f-0b9f43fb468e	History - Grade 10	2026-02-14 19:54:07.799
cmlmqix4n001qqj0182vjiflh	nazareth-baptist	10	bf74d5e3-8880-4044-bc5d-59c76e795b0a	Driving Theory - Grade 10	2026-02-14 19:54:07.799
cmlmqix4n001sqj01igeat1k6	nazareth-baptist	10	211f94bf-9aae-4edc-83b8-5f5f63e54ef7	Electronics - Grade 10	2026-02-14 19:54:07.8
cmlmr8htj000coo01w76mzj8e	nazareth-baptist	12	84a2cd40-c8a1-4cef-a0f8-2bfdb568d2ea	Hebrew - Grade 12	2026-02-14 20:14:01.015
cmlmr8htk000eoo01bc5mwrje	nazareth-baptist	12	bba3b58c-9184-4d7a-a9ff-ac6e08ff38b9	PE - Grade 12	2026-02-14 20:14:01.016
cmlmr8htk000goo016vg7giod	nazareth-baptist	12	5d777c2f-79dd-4675-af7a-62f6c7049fe1	Religion - Grade 12	2026-02-14 20:14:01.017
cmlmr8htl000ioo01d3dlqe3q	nazareth-baptist	12	878c91ad-7133-4ed4-8579-384a44490f76	Chapel - Grade 12	2026-02-14 20:14:01.018
cmlmr8htm000koo013225hai5	nazareth-baptist	12	d99bd5ee-8e30-406a-99d1-97f6eb23d5e6	Math - Grade 12	2026-02-14 20:14:01.018
cmlmr8htm000moo01lgtt7b8r	nazareth-baptist	12	ab43c67a-611e-42b6-b493-40defb03f823	Arabic - Grade 12	2026-02-14 20:14:01.019
cmlmr8htn000ooo01ggztqrtz	nazareth-baptist	12	79c96f2b-1b2b-4862-b069-782f84533050	English - Grade 12	2026-02-14 20:14:01.02
cmlmr8hto000qoo01yuhgm0zx	nazareth-baptist	12	2f445af3-684e-4bda-b5bf-8777d694bff7	Education - Grade 12	2026-02-14 20:14:01.02
cmlmr8hto000soo018c0k7y59	nazareth-baptist	12	5b074a0d-2616-45d7-979f-0b9f43fb468e	History - Grade 12	2026-02-14 20:14:01.021
cmlms1aob000hjv01mfva43lt	nazareth-baptist	10	312fbc07-060f-4b54-a5b2-26cce9d83e65	Research - Grade 10	2026-02-14 20:36:24.779
\.


--
-- Data for Name: ClassroomMember; Type: TABLE DATA; Schema: public; Owner: classmate
--

COPY public."ClassroomMember" (id, "classroomId", "userId", role, "createdAt") FROM stdin;
cmlld20zo000tsc01ppje9da4	cmlld20zj000csc01111ded4h	cmlld20ze0001sc0183k3uvtd	student	2026-02-13 20:49:18.469
cmlld20zo000usc010tglxq3r	cmlld20zk000esc01gt4el84f	cmlld20ze0001sc0183k3uvtd	student	2026-02-13 20:49:18.469
cmlld20zo000vsc01zhv40xbp	cmlld20zl000gsc01n5rr51bp	cmlld20ze0001sc0183k3uvtd	student	2026-02-13 20:49:18.469
cmlld20zo000wsc010kg97bsk	cmlld20zl000isc01ncqsvacq	cmlld20ze0001sc0183k3uvtd	student	2026-02-13 20:49:18.469
cmlld20zo000xsc01udxoluyh	cmlld20zm000ksc01juv6brbk	cmlld20ze0001sc0183k3uvtd	student	2026-02-13 20:49:18.469
cmlld20zo000ysc0194sm0s7e	cmlld20zm000msc01ys89brtj	cmlld20ze0001sc0183k3uvtd	student	2026-02-13 20:49:18.469
cmlld20zo000zsc01b7avqdnd	cmlld20zn000osc018yy57v3h	cmlld20ze0001sc0183k3uvtd	student	2026-02-13 20:49:18.469
cmlld20zo0010sc013emffwa2	cmlld20zn000qsc019cx3lvsh	cmlld20ze0001sc0183k3uvtd	student	2026-02-13 20:49:18.469
cmlld20zo0011sc01lle4f7x1	cmlld20zo000ssc01sr97p9wa	cmlld20ze0001sc0183k3uvtd	student	2026-02-13 20:49:18.469
cmlld84a7000bny010y8sjsdn	cmlld20zj000csc01111ded4h	cmlld849z0001ny01nt0z34dd	student	2026-02-13 20:54:02.672
cmlld84a7000cny01mu5pbmwi	cmlld20zk000esc01gt4el84f	cmlld849z0001ny01nt0z34dd	student	2026-02-13 20:54:02.672
cmlld84a7000dny01dg325yd8	cmlld20zl000gsc01n5rr51bp	cmlld849z0001ny01nt0z34dd	student	2026-02-13 20:54:02.672
cmlld84a7000eny01ha4ckp0u	cmlld20zl000isc01ncqsvacq	cmlld849z0001ny01nt0z34dd	student	2026-02-13 20:54:02.672
cmlld84a7000fny01r2yclqm9	cmlld20zm000ksc01juv6brbk	cmlld849z0001ny01nt0z34dd	student	2026-02-13 20:54:02.672
cmlld84a7000gny01baqct4b6	cmlld20zm000msc01ys89brtj	cmlld849z0001ny01nt0z34dd	student	2026-02-13 20:54:02.672
cmlld84a7000hny01tb3bszd5	cmlld20zn000osc018yy57v3h	cmlld849z0001ny01nt0z34dd	student	2026-02-13 20:54:02.672
cmlld84a7000iny01gccjmy8c	cmlld20zn000qsc019cx3lvsh	cmlld849z0001ny01nt0z34dd	student	2026-02-13 20:54:02.672
cmlld84a7000jny016ebtf4w6	cmlld20zo000ssc01sr97p9wa	cmlld849z0001ny01nt0z34dd	student	2026-02-13 20:54:02.672
cmlldtgsi000vny01e0auz1vq	cmlld20zj000csc01111ded4h	cmlldtgsb000lny011fa2m00w	student	2026-02-13 21:10:38.659
cmlldtgsi000wny01tmd31m86	cmlld20zk000esc01gt4el84f	cmlldtgsb000lny011fa2m00w	student	2026-02-13 21:10:38.659
cmlldtgsi000xny01yb1had7x	cmlld20zl000gsc01n5rr51bp	cmlldtgsb000lny011fa2m00w	student	2026-02-13 21:10:38.659
cmlldtgsi000yny01lfwrrai5	cmlld20zl000isc01ncqsvacq	cmlldtgsb000lny011fa2m00w	student	2026-02-13 21:10:38.659
cmlldtgsi000zny01ounwpyil	cmlld20zm000ksc01juv6brbk	cmlldtgsb000lny011fa2m00w	student	2026-02-13 21:10:38.659
cmlldtgsi0010ny01w10n69l8	cmlld20zm000msc01ys89brtj	cmlldtgsb000lny011fa2m00w	student	2026-02-13 21:10:38.659
cmlldtgsi0011ny01pcgpohe5	cmlld20zn000osc018yy57v3h	cmlldtgsb000lny011fa2m00w	student	2026-02-13 21:10:38.659
cmlldtgsi0012ny015gk8ze0s	cmlld20zn000qsc019cx3lvsh	cmlldtgsb000lny011fa2m00w	student	2026-02-13 21:10:38.659
cmlldtgsi0013ny0131l7xf3o	cmlld20zo000ssc01sr97p9wa	cmlldtgsb000lny011fa2m00w	student	2026-02-13 21:10:38.659
cmlmfts1o000bpf01tegjebtq	cmlld20zj000csc01111ded4h	cmlmfts1g0001pf01gdjhr7u3	student	2026-02-14 14:54:38.653
cmlmfts1o000cpf013z9439ue	cmlld20zk000esc01gt4el84f	cmlmfts1g0001pf01gdjhr7u3	student	2026-02-14 14:54:38.653
cmlmfts1o000dpf01orb22613	cmlld20zl000gsc01n5rr51bp	cmlmfts1g0001pf01gdjhr7u3	student	2026-02-14 14:54:38.653
cmlmfts1o000epf014b1xedq2	cmlld20zl000isc01ncqsvacq	cmlmfts1g0001pf01gdjhr7u3	student	2026-02-14 14:54:38.653
cmlmfts1o000fpf01syrcepbj	cmlld20zm000ksc01juv6brbk	cmlmfts1g0001pf01gdjhr7u3	student	2026-02-14 14:54:38.653
cmlmfts1o000gpf01h5l1xfxt	cmlld20zm000msc01ys89brtj	cmlmfts1g0001pf01gdjhr7u3	student	2026-02-14 14:54:38.653
cmlmfts1o000hpf015dgje9e4	cmlld20zn000osc018yy57v3h	cmlmfts1g0001pf01gdjhr7u3	student	2026-02-14 14:54:38.653
cmlmfts1o000ipf01dgxs812p	cmlld20zn000qsc019cx3lvsh	cmlmfts1g0001pf01gdjhr7u3	student	2026-02-14 14:54:38.653
cmlmfts1o000jpf01aaabldb5	cmlld20zo000ssc01sr97p9wa	cmlmfts1g0001pf01gdjhr7u3	student	2026-02-14 14:54:38.653
cmlmfzbnh001dpf01xl5zbzgm	cmlmfzbnc000wpf01qx16xwsy	cmlmfzbn7000lpf01zzglwtgg	student	2026-02-14 14:58:57.342
cmlmfzbnh001epf018moz12hu	cmlmfzbnd000ypf01ef81npwo	cmlmfzbn7000lpf01zzglwtgg	student	2026-02-14 14:58:57.342
cmlmfzbnh001fpf01bhrlohf8	cmlmfzbne0010pf01e29c13eo	cmlmfzbn7000lpf01zzglwtgg	student	2026-02-14 14:58:57.342
cmlmfzbnh001gpf01oeb566kc	cmlmfzbne0012pf01w3gco9cc	cmlmfzbn7000lpf01zzglwtgg	student	2026-02-14 14:58:57.342
cmlmfzbnh001hpf01l6b3mr96	cmlmfzbnf0014pf012daz2n1i	cmlmfzbn7000lpf01zzglwtgg	student	2026-02-14 14:58:57.342
cmlmfzbnh001ipf010rgewpdx	cmlmfzbng0016pf01n74bw8am	cmlmfzbn7000lpf01zzglwtgg	student	2026-02-14 14:58:57.342
cmlmfzbnh001jpf01qiqz0vj4	cmlmfzbng0018pf01rs4lgkj1	cmlmfzbn7000lpf01zzglwtgg	student	2026-02-14 14:58:57.342
cmlmfzbni001kpf01tlvpybvg	cmlmfzbnh001apf01ocpcdh3a	cmlmfzbn7000lpf01zzglwtgg	student	2026-02-14 14:58:57.342
cmlmfzbni001lpf01fo1ynmjn	cmlmfzbnh001cpf01ir6fz4cq	cmlmfzbn7000lpf01zzglwtgg	student	2026-02-14 14:58:57.342
cmlmgqd4t001xpf01ownbqv2j	cmlld20zj000csc01111ded4h	cmlmgqd4l001npf010agnz6ck	student	2026-02-14 15:19:58.973
cmlmgqd4t001ypf01b6h9oytp	cmlld20zk000esc01gt4el84f	cmlmgqd4l001npf010agnz6ck	student	2026-02-14 15:19:58.973
cmlmgqd4t001zpf01bbnwro0o	cmlld20zl000gsc01n5rr51bp	cmlmgqd4l001npf010agnz6ck	student	2026-02-14 15:19:58.973
cmlmgqd4t0020pf01cf9lh2ne	cmlld20zl000isc01ncqsvacq	cmlmgqd4l001npf010agnz6ck	student	2026-02-14 15:19:58.973
cmlmgqd4t0021pf01poewv6ue	cmlld20zm000ksc01juv6brbk	cmlmgqd4l001npf010agnz6ck	student	2026-02-14 15:19:58.973
cmlmgqd4t0022pf016f0t2djo	cmlld20zm000msc01ys89brtj	cmlmgqd4l001npf010agnz6ck	student	2026-02-14 15:19:58.973
cmlmgqd4t0023pf011u3z8f5a	cmlld20zn000osc018yy57v3h	cmlmgqd4l001npf010agnz6ck	student	2026-02-14 15:19:58.973
cmlmgqd4t0024pf011g6yo9ye	cmlld20zn000qsc019cx3lvsh	cmlmgqd4l001npf010agnz6ck	student	2026-02-14 15:19:58.973
cmlmgqd4t0025pf016h585p0q	cmlld20zo000ssc01sr97p9wa	cmlmgqd4l001npf010agnz6ck	student	2026-02-14 15:19:58.973
cmlmhk3ho002hpf01r0ymju1e	cmlmfzbnc000wpf01qx16xwsy	cmlmhk3hg0027pf01cwt0fupx	student	2026-02-14 15:43:06.156
cmlmhk3ho002ipf01dmf7vluw	cmlmfzbnd000ypf01ef81npwo	cmlmhk3hg0027pf01cwt0fupx	student	2026-02-14 15:43:06.156
cmlmhk3ho002jpf01h7zr1qea	cmlmfzbne0010pf01e29c13eo	cmlmhk3hg0027pf01cwt0fupx	student	2026-02-14 15:43:06.156
cmlmhk3ho002kpf01bujzntzn	cmlmfzbne0012pf01w3gco9cc	cmlmhk3hg0027pf01cwt0fupx	student	2026-02-14 15:43:06.156
cmlmhk3ho002lpf01urd849y5	cmlmfzbnf0014pf012daz2n1i	cmlmhk3hg0027pf01cwt0fupx	student	2026-02-14 15:43:06.156
cmlmhk3ho002mpf01obv1ydqr	cmlmfzbng0016pf01n74bw8am	cmlmhk3hg0027pf01cwt0fupx	student	2026-02-14 15:43:06.156
cmlmhk3ho002npf01t4u44dzs	cmlmfzbng0018pf01rs4lgkj1	cmlmhk3hg0027pf01cwt0fupx	student	2026-02-14 15:43:06.156
cmlmhk3ho002opf015ospfft8	cmlmfzbnh001apf01ocpcdh3a	cmlmhk3hg0027pf01cwt0fupx	student	2026-02-14 15:43:06.156
cmlmhk3ho002ppf01zx7l9gnc	cmlmfzbnh001cpf01ir6fz4cq	cmlmhk3hg0027pf01cwt0fupx	student	2026-02-14 15:43:06.156
cmlmhpju1002zpf01zvwuni2a	cmlld20zj000csc01111ded4h	cmlmhpjtw002rpf01dswhe3mn	student	2026-02-14 15:47:20.618
cmlmhpju10030pf017on6kdl6	cmlld20zk000esc01gt4el84f	cmlmhpjtw002rpf01dswhe3mn	student	2026-02-14 15:47:20.618
cmlmhpju10031pf012qu9ivz4	cmlld20zl000gsc01n5rr51bp	cmlmhpjtw002rpf01dswhe3mn	student	2026-02-14 15:47:20.618
cmlmhpju10032pf01yb0mcwr6	cmlld20zl000isc01ncqsvacq	cmlmhpjtw002rpf01dswhe3mn	student	2026-02-14 15:47:20.618
cmlmhpju10033pf017837akam	cmlld20zm000ksc01juv6brbk	cmlmhpjtw002rpf01dswhe3mn	student	2026-02-14 15:47:20.618
cmlmhpju10034pf011f4i87ns	cmlld20zm000msc01ys89brtj	cmlmhpjtw002rpf01dswhe3mn	student	2026-02-14 15:47:20.618
cmlmhpju10035pf01wgncamwl	cmlld20zn000osc018yy57v3h	cmlmhpjtw002rpf01dswhe3mn	student	2026-02-14 15:47:20.618
cmlmi3fur003fpf01rfm2tsda	cmlld20zj000csc01111ded4h	cmlmi3ful0037pf01mlb614dc	student	2026-02-14 15:58:08.643
cmlmi3fur003gpf01bmp81ero	cmlld20zk000esc01gt4el84f	cmlmi3ful0037pf01mlb614dc	student	2026-02-14 15:58:08.643
cmlmi3fur003hpf01d82ygl16	cmlld20zl000gsc01n5rr51bp	cmlmi3ful0037pf01mlb614dc	student	2026-02-14 15:58:08.643
cmlmi3fur003ipf018br33j44	cmlld20zl000isc01ncqsvacq	cmlmi3ful0037pf01mlb614dc	student	2026-02-14 15:58:08.643
cmlmi3fur003jpf015jwbgubs	cmlld20zm000ksc01juv6brbk	cmlmi3ful0037pf01mlb614dc	student	2026-02-14 15:58:08.643
cmlmi3fur003kpf01s0755iv9	cmlld20zm000msc01ys89brtj	cmlmi3ful0037pf01mlb614dc	student	2026-02-14 15:58:08.643
cmlmi3fur003lpf01hsa127bc	cmlld20zn000osc018yy57v3h	cmlmi3ful0037pf01mlb614dc	student	2026-02-14 15:58:08.643
cmlmi8igl003wpf013ti483f4	cmlld20zj000csc01111ded4h	cmlmi8ige003npf01bbc9gwgy	student	2026-02-14 16:02:05.302
cmlmi8igl003xpf01d3fb9cd8	cmlld20zk000esc01gt4el84f	cmlmi8ige003npf01bbc9gwgy	student	2026-02-14 16:02:05.302
cmlmi8igl003ypf01q77ocwns	cmlld20zl000gsc01n5rr51bp	cmlmi8ige003npf01bbc9gwgy	student	2026-02-14 16:02:05.302
cmlmi8igl003zpf014z4xcdam	cmlld20zl000isc01ncqsvacq	cmlmi8ige003npf01bbc9gwgy	student	2026-02-14 16:02:05.302
cmlmi8igl0040pf014utljguf	cmlld20zm000ksc01juv6brbk	cmlmi8ige003npf01bbc9gwgy	student	2026-02-14 16:02:05.302
cmlmi8igl0041pf01twu3jtvi	cmlld20zm000msc01ys89brtj	cmlmi8ige003npf01bbc9gwgy	student	2026-02-14 16:02:05.302
cmlmi8igl0042pf017n8fzism	cmlld20zn000osc018yy57v3h	cmlmi8ige003npf01bbc9gwgy	student	2026-02-14 16:02:05.302
cmlmi8igl0043pf019uipgvtm	cmlld20zn000qsc019cx3lvsh	cmlmi8ige003npf01bbc9gwgy	student	2026-02-14 16:02:05.302
cmlmi956v004jpf01pg1i8c8n	cmlld20zj000csc01111ded4h	cmlmi956o0045pf01quuhuv2g	student	2026-02-14 16:02:34.76
cmlmi956v004kpf010c5h4xu2	cmlld20zk000esc01gt4el84f	cmlmi956o0045pf01quuhuv2g	student	2026-02-14 16:02:34.76
cmlmi956v004lpf012ddmykvf	cmlld20zl000gsc01n5rr51bp	cmlmi956o0045pf01quuhuv2g	student	2026-02-14 16:02:34.76
cmlmi956v004mpf01yb1k53m3	cmlld20zl000isc01ncqsvacq	cmlmi956o0045pf01quuhuv2g	student	2026-02-14 16:02:34.76
cmlmi956v004npf017w6ug4jf	cmlld20zm000ksc01juv6brbk	cmlmi956o0045pf01quuhuv2g	student	2026-02-14 16:02:34.76
cmlmi956v004opf012kpraiuq	cmlld20zm000msc01ys89brtj	cmlmi956o0045pf01quuhuv2g	student	2026-02-14 16:02:34.76
cmlmi956v004ppf01pdvytuge	cmlld20zn000osc018yy57v3h	cmlmi956o0045pf01quuhuv2g	student	2026-02-14 16:02:34.76
cmlmi956v004qpf01w8pnrrhr	cmlmi956u004gpf01ri1ok854	cmlmi956o0045pf01quuhuv2g	student	2026-02-14 16:02:34.76
cmlmi956v004rpf0117hnar3s	cmlmi956v004ipf011g01fnpb	cmlmi956o0045pf01quuhuv2g	student	2026-02-14 16:02:34.76
cmlmm71kr000ali01259iaro0	cmlld20zj000csc01111ded4h	cmlmm71kj0001li0149ow96ih	student	2026-02-14 17:52:55.227
cmlmm71kr000bli01kgyddt3k	cmlld20zk000esc01gt4el84f	cmlmm71kj0001li0149ow96ih	student	2026-02-14 17:52:55.227
cmlmm71kr000cli01b0m225mg	cmlld20zl000gsc01n5rr51bp	cmlmm71kj0001li0149ow96ih	student	2026-02-14 17:52:55.227
cmlmm71kr000dli01hhc8scz8	cmlld20zl000isc01ncqsvacq	cmlmm71kj0001li0149ow96ih	student	2026-02-14 17:52:55.227
cmlmm71kr000eli01m17wp0ti	cmlld20zm000ksc01juv6brbk	cmlmm71kj0001li0149ow96ih	student	2026-02-14 17:52:55.227
cmlmm71kr000fli01jhosgxhq	cmlld20zm000msc01ys89brtj	cmlmm71kj0001li0149ow96ih	student	2026-02-14 17:52:55.227
cmlmm71kr000gli01amdfli7u	cmlld20zn000osc018yy57v3h	cmlmm71kj0001li0149ow96ih	student	2026-02-14 17:52:55.227
cmlmm71kr000hli01qw5cx37w	cmlmi956v004ipf011g01fnpb	cmlmm71kj0001li0149ow96ih	student	2026-02-14 17:52:55.227
cmlmq65h5000jqj01kvvy6z3b	cmlld20zk000esc01gt4el84f	cmlmq65gt0001qj01cygw4mly	student	2026-02-14 19:44:12.09
cmlmq65h5000kqj019z34uwtz	cmlld20zl000gsc01n5rr51bp	cmlmq65gt0001qj01cygw4mly	student	2026-02-14 19:44:12.09
cmlmq65h5000lqj01gs6uquoe	cmlld20zl000isc01ncqsvacq	cmlmq65gt0001qj01cygw4mly	student	2026-02-14 19:44:12.09
cmlmq65h5000mqj01j8pdoeab	cmlld20zm000ksc01juv6brbk	cmlmq65gt0001qj01cygw4mly	student	2026-02-14 19:44:12.09
cmlmq65h5000nqj01opiajas1	cmlld20zn000osc018yy57v3h	cmlmq65gt0001qj01cygw4mly	student	2026-02-14 19:44:12.09
cmlmq65h5000oqj01wbci1vvs	cmlld20zj000csc01111ded4h	cmlmq65gt0001qj01cygw4mly	student	2026-02-14 19:44:12.09
cmlmq65h5000pqj01mnngxzai	cmlld20zm000msc01ys89brtj	cmlmq65gt0001qj01cygw4mly	student	2026-02-14 19:44:12.09
cmlmq65h5000qqj01pj1hdw1i	cmlmq65h3000eqj014cixuhz0	cmlmq65gt0001qj01cygw4mly	student	2026-02-14 19:44:12.09
cmlmq65h5000rqj01ul9du32a	cmlmq65h4000gqj01vdpm137c	cmlmq65gt0001qj01cygw4mly	student	2026-02-14 19:44:12.09
cmlmq65h5000sqj01eqqybjxm	cmlmq65h4000iqj015vm752gl	cmlmq65gt0001qj01cygw4mly	student	2026-02-14 19:44:12.09
cmlmq65h5000tqj011rqxeyxx	cmlmi956v004ipf011g01fnpb	cmlmq65gt0001qj01cygw4mly	student	2026-02-14 19:44:12.09
cmlmqix4o001tqj01hv4qxsnc	cmlmqix4i0018qj01b3a4anjo	cmlmqix4c000vqj01g91a2t82	student	2026-02-14 19:54:07.8
cmlmqix4o001uqj01pmgry3or	cmlmqix4i001aqj01of345zha	cmlmqix4c000vqj01g91a2t82	student	2026-02-14 19:54:07.8
cmlmqix4o001vqj01fw9gblir	cmlmqix4j001cqj01l1gocyxw	cmlmqix4c000vqj01g91a2t82	student	2026-02-14 19:54:07.8
cmlmqix4o001wqj011rhne23h	cmlmqix4k001eqj01ojw3z9xg	cmlmqix4c000vqj01g91a2t82	student	2026-02-14 19:54:07.8
cmlmqix4o001xqj01nam3q9lc	cmlmqix4k001gqj01td1fqbkv	cmlmqix4c000vqj01g91a2t82	student	2026-02-14 19:54:07.8
cmlmqix4o001yqj01d9l2hqd3	cmlmqix4l001iqj01uvkwp585	cmlmqix4c000vqj01g91a2t82	student	2026-02-14 19:54:07.8
cmlmqix4o001zqj01ymte6tcd	cmlmqix4l001kqj01hd2i4ioe	cmlmqix4c000vqj01g91a2t82	student	2026-02-14 19:54:07.8
cmlmqix4o0020qj018rp4zhgr	cmlmqix4m001mqj01u9n67o52	cmlmqix4c000vqj01g91a2t82	student	2026-02-14 19:54:07.8
cmlmqix4o0021qj01vkeiy1sv	cmlmqix4m001oqj01u6crj0u4	cmlmqix4c000vqj01g91a2t82	student	2026-02-14 19:54:07.8
cmlmqix4o0022qj01ybodaut9	cmlmqix4n001qqj0182vjiflh	cmlmqix4c000vqj01g91a2t82	student	2026-02-14 19:54:07.8
cmlmqix4o0023qj01y8eaa6zj	cmlmqix4n001sqj01igeat1k6	cmlmqix4c000vqj01g91a2t82	student	2026-02-14 19:54:07.8
cmlmqzjpd000flx01je9n7kgu	cmlmqix4i0018qj01b3a4anjo	cmlmqzjp20003lx01dlji44js	student	2026-02-14 20:07:03.553
cmlmqzjpd000glx01lpa2cdai	cmlmqix4i001aqj01of345zha	cmlmqzjp20003lx01dlji44js	student	2026-02-14 20:07:03.553
cmlmqzjpd000hlx01yhkc0fco	cmlmqix4j001cqj01l1gocyxw	cmlmqzjp20003lx01dlji44js	student	2026-02-14 20:07:03.553
cmlmqzjpd000ilx01occ4yb38	cmlmqix4k001eqj01ojw3z9xg	cmlmqzjp20003lx01dlji44js	student	2026-02-14 20:07:03.553
cmlmqzjpd000jlx01dvyhz3fw	cmlmqix4k001gqj01td1fqbkv	cmlmqzjp20003lx01dlji44js	student	2026-02-14 20:07:03.553
cmlmqzjpd000klx01mptca05n	cmlmqix4l001iqj01uvkwp585	cmlmqzjp20003lx01dlji44js	student	2026-02-14 20:07:03.553
cmlmqzjpd000llx01hcmbgb0r	cmlmqix4l001kqj01hd2i4ioe	cmlmqzjp20003lx01dlji44js	student	2026-02-14 20:07:03.553
cmlmqzjpd000mlx01deoxc2zu	cmlmqix4m001mqj01u9n67o52	cmlmqzjp20003lx01dlji44js	student	2026-02-14 20:07:03.553
cmlmqzjpd000nlx01lb7hofol	cmlmqix4m001oqj01u6crj0u4	cmlmqzjp20003lx01dlji44js	student	2026-02-14 20:07:03.553
cmlmqzjpd000olx01hcr7nqpn	cmlmqix4n001qqj0182vjiflh	cmlmqzjp20003lx01dlji44js	student	2026-02-14 20:07:03.553
cmlmqzjpd000plx01w0vk6jsw	cmlmqix4n001sqj01igeat1k6	cmlmqzjp20003lx01dlji44js	student	2026-02-14 20:07:03.553
cmlmr8hto000too01uc3xqza6	cmlmr8htj000coo01w76mzj8e	cmlmr8hte0001oo01xhbsm3r6	student	2026-02-14 20:14:01.021
cmlmr8hto000uoo01kqb283la	cmlmr8htk000eoo01bc5mwrje	cmlmr8hte0001oo01xhbsm3r6	student	2026-02-14 20:14:01.021
cmlmr8hto000voo01yyacevwr	cmlmr8htk000goo016vg7giod	cmlmr8hte0001oo01xhbsm3r6	student	2026-02-14 20:14:01.021
cmlmr8hto000woo010bffsulf	cmlmr8htl000ioo01d3dlqe3q	cmlmr8hte0001oo01xhbsm3r6	student	2026-02-14 20:14:01.021
cmlmr8hto000xoo01ljao3i7u	cmlmr8htm000koo013225hai5	cmlmr8hte0001oo01xhbsm3r6	student	2026-02-14 20:14:01.021
cmlmr8hto000zoo01qb6fsfzz	cmlmr8htn000ooo01ggztqrtz	cmlmr8hte0001oo01xhbsm3r6	student	2026-02-14 20:14:01.021
cmlmr8hto0010oo01j26rb4fe	cmlmr8hto000qoo01yuhgm0zx	cmlmr8hte0001oo01xhbsm3r6	student	2026-02-14 20:14:01.021
cmlmr8hto0011oo01c6irjuqu	cmlmr8hto000soo018c0k7y59	cmlmr8hte0001oo01xhbsm3r6	student	2026-02-14 20:14:01.021
cmlmr8u9o001foo01kb0r4kka	cmlmqix4i0018qj01b3a4anjo	cmlmr8u9f0013oo01dnu9fp3d	student	2026-02-14 20:14:17.148
cmlmr8u9o001goo01bwc3kscl	cmlmqix4i001aqj01of345zha	cmlmr8u9f0013oo01dnu9fp3d	student	2026-02-14 20:14:17.148
cmlmr8u9o001hoo011vrysmeq	cmlmqix4j001cqj01l1gocyxw	cmlmr8u9f0013oo01dnu9fp3d	student	2026-02-14 20:14:17.148
cmlmr8u9o001ioo01irkjxzv0	cmlmqix4k001eqj01ojw3z9xg	cmlmr8u9f0013oo01dnu9fp3d	student	2026-02-14 20:14:17.148
cmlmr8u9o001joo016c76rdl6	cmlmqix4k001gqj01td1fqbkv	cmlmr8u9f0013oo01dnu9fp3d	student	2026-02-14 20:14:17.148
cmlmr8u9o001koo01fpniyfkr	cmlmqix4l001iqj01uvkwp585	cmlmr8u9f0013oo01dnu9fp3d	student	2026-02-14 20:14:17.148
cmlmr8u9o001loo01pjfzipqh	cmlmqix4l001kqj01hd2i4ioe	cmlmr8u9f0013oo01dnu9fp3d	student	2026-02-14 20:14:17.148
cmlmr8u9o001moo01meqa03io	cmlmqix4m001mqj01u9n67o52	cmlmr8u9f0013oo01dnu9fp3d	student	2026-02-14 20:14:17.148
cmlmr8u9o001noo01a5gwfab6	cmlmqix4m001oqj01u6crj0u4	cmlmr8u9f0013oo01dnu9fp3d	student	2026-02-14 20:14:17.148
cmlmr8u9o001ooo01fodx8wq5	cmlmqix4n001qqj0182vjiflh	cmlmr8u9f0013oo01dnu9fp3d	student	2026-02-14 20:14:17.148
cmlmr8u9o001poo01kfmmiwuo	cmlmqix4n001sqj01igeat1k6	cmlmr8u9f0013oo01dnu9fp3d	student	2026-02-14 20:14:17.148
cmlms1aob000ijv016ib300nu	cmlmqix4i0018qj01b3a4anjo	cmlms1ao20003jv01zyhz4ej1	student	2026-02-14 20:36:24.78
cmlms1aob000jjv01j7mswgis	cmlmqix4i001aqj01of345zha	cmlms1ao20003jv01zyhz4ej1	student	2026-02-14 20:36:24.78
cmlms1aob000kjv018xojiq52	cmlmqix4j001cqj01l1gocyxw	cmlms1ao20003jv01zyhz4ej1	student	2026-02-14 20:36:24.78
cmlms1aob000ljv015x8u6r2a	cmlmqix4k001eqj01ojw3z9xg	cmlms1ao20003jv01zyhz4ej1	student	2026-02-14 20:36:24.78
cmlms1aob000mjv01h0q7j125	cmlmqix4k001gqj01td1fqbkv	cmlms1ao20003jv01zyhz4ej1	student	2026-02-14 20:36:24.78
cmlms1aob000njv01may5nj85	cmlmqix4l001iqj01uvkwp585	cmlms1ao20003jv01zyhz4ej1	student	2026-02-14 20:36:24.78
cmlms1aob000ojv01n3hnsbt3	cmlmqix4l001kqj01hd2i4ioe	cmlms1ao20003jv01zyhz4ej1	student	2026-02-14 20:36:24.78
cmlms1aob000pjv01gevawsab	cmlmqix4m001mqj01u9n67o52	cmlms1ao20003jv01zyhz4ej1	student	2026-02-14 20:36:24.78
cmlms1aob000qjv01r6h5z3nf	cmlmqix4m001oqj01u6crj0u4	cmlms1ao20003jv01zyhz4ej1	student	2026-02-14 20:36:24.78
cmlms1aob000rjv01c17kri77	cmlmqix4n001qqj0182vjiflh	cmlms1ao20003jv01zyhz4ej1	student	2026-02-14 20:36:24.78
cmlms1aob000sjv01i0ede7gq	cmlmqix4n001sqj01igeat1k6	cmlms1ao20003jv01zyhz4ej1	student	2026-02-14 20:36:24.78
cmlms1aob000tjv0198iv97yi	cmlms1aob000hjv01mfva43lt	cmlms1ao20003jv01zyhz4ej1	student	2026-02-14 20:36:24.78
cm_e79287b84804	cmlmr8htm000moo01lgtt7b8r	cmlms1ao20003jv01zyhz4ej1	student	2026-02-15 13:53:34.025
\.


--
-- Data for Name: Grade; Type: TABLE DATA; Schema: public; Owner: classmate
--

COPY public."Grade" (id, "userId", "subjectId", title, score, "maxScore", date, "createdAt") FROM stdin;
\.


--
-- Data for Name: GradeSubjectPack; Type: TABLE DATA; Schema: public; Owner: classmate
--

COPY public."GradeSubjectPack" (id, grade, kind, "subjectId", "createdAt", "schoolId") FROM stdin;
8ab8dacf-646e-4a19-87ec-4853fadc5e6c	4	grade	sub_hebrew	2026-02-14 19:36:44.863	demo-school
64ad3be6-21f9-4de0-a796-0026a31b213a	4	grade	sub_pe	2026-02-14 19:36:44.863	demo-school
4e7f7dc7-e28c-4c71-8e61-712600f71cd6	4	grade	sub_religion	2026-02-14 19:36:44.863	demo-school
23ac0ae1-c63f-47a8-9a49-5aecd75f1bd6	4	grade	sub_chapel	2026-02-14 19:36:44.863	demo-school
b2e124ef-728c-479c-8036-a022354fa869	4	grade	sub_math	2026-02-14 19:36:44.863	demo-school
ec0578f7-5399-4398-8ba2-cf0e19d3233f	4	grade	sub_arabic	2026-02-14 19:36:44.863	demo-school
1984f702-f869-4447-bb53-adf46d81fc5c	4	grade	sub_english	2026-02-14 19:36:44.863	demo-school
dc589d08-e106-4c8c-9d31-0fc0ef0ab8d1	4	grade	13e66761-da74-4866-88e5-7d2fa588dc87	2026-02-14 19:36:44.863	demo-school
b59e463f-d4e6-4bcf-a2e7-d0b39834b12b	4	grade	bd44d7be-b5d3-4230-8346-eab39774957c	2026-02-14 19:36:44.863	demo-school
e53f3253-842b-4de5-ba25-f965bf919916	4	grade	e46f7830-d205-438d-ad36-67364bdf7b7e	2026-02-14 19:36:44.863	demo-school
b07767ff-fdbe-42ac-b988-282faa15db17	5	grade	sub_hebrew	2026-02-14 19:36:44.864	demo-school
a32d9314-89d6-48ce-a427-f499bc1ce2b8	5	grade	sub_pe	2026-02-14 19:36:44.864	demo-school
b3f43ed4-b670-49b5-9aa5-d8d875bdf6cc	5	grade	sub_religion	2026-02-14 19:36:44.864	demo-school
b93d1637-9cee-462c-aa1e-4cc425a1b9cf	5	grade	sub_chapel	2026-02-14 19:36:44.864	demo-school
cb591a2a-f002-43f1-9574-7a9c85ad4001	5	grade	sub_math	2026-02-14 19:36:44.864	demo-school
57a82b7f-8639-4447-992d-449fbe76cef3	5	grade	sub_arabic	2026-02-14 19:36:44.864	demo-school
fa22625b-50cc-4ab2-8112-14b87409a643	5	grade	sub_english	2026-02-14 19:36:44.864	demo-school
4be03691-b090-42dc-a4c6-c421fad5e3f4	5	grade	13e66761-da74-4866-88e5-7d2fa588dc87	2026-02-14 19:36:44.864	demo-school
fdf2316b-e269-41fc-abd7-561fea4da7cc	5	grade	bd44d7be-b5d3-4230-8346-eab39774957c	2026-02-14 19:36:44.864	demo-school
b3ccd257-81e8-4bbf-9cb7-ff0d881b457d	5	grade	4e94e5a1-9df3-45b9-9d31-2c6321aeeb23	2026-02-14 19:36:44.864	demo-school
2f9d1a01-4c08-4146-b8f0-c5fadc65b2ac	5	grade	e46f7830-d205-438d-ad36-67364bdf7b7e	2026-02-14 19:36:44.864	demo-school
a74fdf12-d94a-42c4-bfb8-1b1613008401	6	grade	sub_hebrew	2026-02-14 19:36:44.865	demo-school
984dcddf-4bb1-44ed-86e9-2fa78a482b46	6	grade	sub_pe	2026-02-14 19:36:44.865	demo-school
8add4138-c1ad-4e79-9011-695f1706c131	6	grade	sub_religion	2026-02-14 19:36:44.865	demo-school
90ad6d55-c2c1-46c4-8dc8-b7fc0f77e9bf	6	grade	sub_chapel	2026-02-14 19:36:44.865	demo-school
4528e302-62a3-473d-b753-560cecc75500	6	grade	sub_math	2026-02-14 19:36:44.865	demo-school
0b910160-bf68-4f88-a6df-f4877e60cc20	6	grade	sub_arabic	2026-02-14 19:36:44.865	demo-school
08a39a96-3ed4-4afe-b8f5-655f0b0750cd	6	grade	sub_english	2026-02-14 19:36:44.865	demo-school
f6797f2d-0b46-43b2-9630-037dc4bc7dde	6	grade	13e66761-da74-4866-88e5-7d2fa588dc87	2026-02-14 19:36:44.865	demo-school
0a44af2c-ca7e-4062-a72f-1cb07945aa07	6	grade	bd44d7be-b5d3-4230-8346-eab39774957c	2026-02-14 19:36:44.865	demo-school
fac4340e-cd6d-4bb5-8133-276fb2259716	6	grade	e46f7830-d205-438d-ad36-67364bdf7b7e	2026-02-14 19:36:44.865	demo-school
0c9ee564-602c-4e1d-b6cc-270cd1933002	7	grade	sub_hebrew	2026-02-14 19:36:44.865	demo-school
6a3a920d-372f-48d6-9c40-87d5ff0edede	7	grade	sub_pe	2026-02-14 19:36:44.865	demo-school
8388c116-fe04-46e5-abcc-9f927dfc276d	7	grade	sub_religion	2026-02-14 19:36:44.865	demo-school
7713f05b-dc89-4790-bcef-bdd21886b435	7	grade	sub_chapel	2026-02-14 19:36:44.865	demo-school
b4d391ec-33fb-4e07-a4be-8e0befebb37c	7	grade	sub_chemistry	2026-02-14 19:36:44.865	demo-school
4a65f843-81be-4dd1-ae46-57148870bf42	7	grade	sub_biology	2026-02-14 19:36:44.865	demo-school
212d8fa9-d084-4dcc-bae8-886554c8fd36	7	grade	sub_electronics	2026-02-14 19:36:44.865	demo-school
c55e466a-4179-4253-93fb-ab6aa43510a8	7	grade	sub_math	2026-02-14 19:36:44.865	demo-school
6ba48ac6-d67b-4570-9a8b-5072fb51e570	7	grade	sub_arabic	2026-02-14 19:36:44.865	demo-school
f1827e68-ef52-45a0-a09a-e7d1f183924f	7	grade	sub_english	2026-02-14 19:36:44.865	demo-school
398c41ff-65d9-45cf-8f61-f21269763721	7	grade	13e66761-da74-4866-88e5-7d2fa588dc87	2026-02-14 19:36:44.865	demo-school
1158b9bf-d014-4f4e-a64d-41254cccdcea	7	grade	052a07e9-7224-4531-b063-f841e349036c	2026-02-14 19:36:44.865	demo-school
af9ec3d5-2e55-42a9-92ad-65b7d95028fb	7	grade	bd44d7be-b5d3-4230-8346-eab39774957c	2026-02-14 19:36:44.865	demo-school
ca8f1653-52bb-4730-ab26-f3f2a8131139	8	grade	sub_hebrew	2026-02-14 19:36:44.866	demo-school
be93ac1d-017c-4fc9-a532-8926a32c0703	8	grade	sub_pe	2026-02-14 19:36:44.866	demo-school
69fc191b-7dff-4c87-a9d1-7bc0535144d8	8	grade	sub_religion	2026-02-14 19:36:44.866	demo-school
d8674e9a-d88a-4fdf-8a8d-1fce92aa8558	8	grade	sub_chapel	2026-02-14 19:36:44.866	demo-school
8df605b4-5003-47ac-b643-370adc12a584	8	grade	sub_chemistry	2026-02-14 19:36:44.866	demo-school
c55f5dc1-f582-4263-b2c1-b0146c131f2c	8	grade	sub_biology	2026-02-14 19:36:44.866	demo-school
f4a004cf-56c0-4bab-b473-810dc5d92019	8	grade	sub_electronics	2026-02-14 19:36:44.866	demo-school
dfd47694-eaad-49d3-8a91-e1d989fbab1f	8	grade	sub_math	2026-02-14 19:36:44.866	demo-school
6d14625b-efbd-4b8a-bbcf-fb2aec96cba8	8	grade	sub_arabic	2026-02-14 19:36:44.866	demo-school
b5d07782-8719-4b41-b1ee-a10ac374b818	8	grade	sub_english	2026-02-14 19:36:44.866	demo-school
21f60530-66cb-4438-a78e-583aba800f04	8	grade	13e66761-da74-4866-88e5-7d2fa588dc87	2026-02-14 19:36:44.866	demo-school
ed3d0648-fda9-4bcf-bd19-2d83bfadbf16	8	grade	052a07e9-7224-4531-b063-f841e349036c	2026-02-14 19:36:44.866	demo-school
899e8351-239f-4195-ba98-b2083ad9e971	8	grade	bd44d7be-b5d3-4230-8346-eab39774957c	2026-02-14 19:36:44.866	demo-school
927b3be0-ec92-43d2-93aa-1686ddcc1997	8	grade	d75a8037-7868-4178-84f5-f4e6bda4e294	2026-02-14 19:36:44.866	demo-school
11e32774-3504-40a2-a064-25b3b4ea1a51	9	grade	sub_hebrew	2026-02-14 19:36:44.866	demo-school
7f5f744b-3f16-4aa3-8b2e-97c38fc6f8d6	9	grade	sub_pe	2026-02-14 19:36:44.866	demo-school
e14bb514-f9a6-4798-a340-57ca54a75741	9	grade	sub_religion	2026-02-14 19:36:44.866	demo-school
1894d454-92bd-4f99-91fb-02a0440de9f3	9	grade	sub_chapel	2026-02-14 19:36:44.866	demo-school
ac8f715e-4de5-479c-b8e3-2b4e5d5acb7e	9	grade	sub_chemistry	2026-02-14 19:36:44.866	demo-school
39fb8aa9-d1ab-4d6d-80f7-0aa112e6e4a7	9	grade	sub_biology	2026-02-14 19:36:44.866	demo-school
b01b3812-75b9-4089-93a5-e3987c9bad51	9	grade	sub_electronics	2026-02-14 19:36:44.866	demo-school
2abe9392-53ec-4797-ba5e-8536b18f761a	9	grade	sub_physics	2026-02-14 19:36:44.866	demo-school
6d12e437-5c63-4390-84e0-96e92ef845f0	9	grade	sub_math	2026-02-14 19:36:44.866	demo-school
45ca48d3-73e2-49d6-b88b-6386db6b0907	9	grade	sub_arabic	2026-02-14 19:36:44.866	demo-school
bbd10b31-7a7a-424e-b38a-adad87a00438	9	grade	sub_english	2026-02-14 19:36:44.866	demo-school
39bb2655-fc3f-4270-bd25-15308480361c	9	grade	13e66761-da74-4866-88e5-7d2fa588dc87	2026-02-14 19:36:44.866	demo-school
b939c660-d246-4265-94ee-8963ddca062e	9	grade	052a07e9-7224-4531-b063-f841e349036c	2026-02-14 19:36:44.866	demo-school
085b3749-d19e-43cc-b867-aa372b4786ed	9	grade	4e94e5a1-9df3-45b9-9d31-2c6321aeeb23	2026-02-14 19:36:44.866	demo-school
0b7b4392-0530-4633-9f51-023adba7148c	10	grade	sub_hebrew	2026-02-14 19:43:55.495	demo-school
96d38910-6a59-43d6-8dc5-b3d8426a05e9	10	grade	sub_pe	2026-02-14 19:43:55.495	demo-school
7f4dba20-8816-40f9-a038-de3c484201b1	10	grade	sub_religion	2026-02-14 19:43:55.495	demo-school
801eabe5-e6ff-492e-ae1b-e0d8a5f1bf32	10	grade	sub_chapel	2026-02-14 19:43:55.495	demo-school
e16a813d-ca41-4b51-8402-05d7459ec10c	10	grade	sub_math	2026-02-14 19:43:55.495	demo-school
3d4acc30-3889-4cc9-8574-70a64b0b2c6e	10	grade	sub_arabic	2026-02-14 19:43:55.495	demo-school
305617b4-6998-4498-881d-f2d4deb8c6fd	10	grade	sub_english	2026-02-14 19:43:55.495	demo-school
5b6c4c43-be3c-4a16-92bd-75afe9cb343e	10	grade	13e66761-da74-4866-88e5-7d2fa588dc87	2026-02-14 19:43:55.495	demo-school
0b63f69e-e2e0-45d4-b7c4-c81788c2620c	10	grade	052a07e9-7224-4531-b063-f841e349036c	2026-02-14 19:43:55.495	demo-school
516db81d-99f6-4db6-9026-eb9d8206200d	10	grade	d3db3f9d-2269-4d5e-9ac5-5461d27d4531	2026-02-14 19:43:55.495	demo-school
103b3dd2-0ec7-4fae-8fff-4b3fa8107036	11	grade	sub_hebrew	2026-02-14 19:43:55.497	demo-school
c46351e2-3f94-472b-b3e4-d86fa5f3cc96	11	grade	sub_pe	2026-02-14 19:43:55.497	demo-school
bc9d1652-87c0-40bd-bc97-71475ce43f19	11	grade	sub_religion	2026-02-14 19:43:55.497	demo-school
b94a20fc-4825-47eb-bc05-9d575b0e10b4	11	grade	sub_chapel	2026-02-14 19:43:55.497	demo-school
8ee85c56-73ac-4000-b0df-cc59f8845035	11	grade	sub_math	2026-02-14 19:43:55.497	demo-school
e9bc076a-f489-4857-956b-658b8c761b16	11	grade	sub_arabic	2026-02-14 19:43:55.497	demo-school
e77a3a28-6ef8-444a-9994-1655500735d9	11	grade	sub_english	2026-02-14 19:43:55.497	demo-school
2b2e364c-3c35-45c0-b1d7-7bd40db0f16e	11	grade	13e66761-da74-4866-88e5-7d2fa588dc87	2026-02-14 19:43:55.497	demo-school
0183cdf8-12ce-406d-8fd6-0d5fe5e95684	11	grade	052a07e9-7224-4531-b063-f841e349036c	2026-02-14 19:43:55.497	demo-school
47a44a4d-c90b-41a3-bb46-fc7eafd3d4d5	12	grade	sub_hebrew	2026-02-14 19:43:55.497	demo-school
199ebe6d-ddd1-41ae-abc9-ccc0f274ff4b	12	grade	sub_pe	2026-02-14 19:43:55.497	demo-school
4ac3b9ba-a858-430f-8d9c-2263f1199294	12	grade	sub_religion	2026-02-14 19:43:55.497	demo-school
11fa80cf-6c8d-4276-b615-fd6d95d87f9b	12	grade	sub_chapel	2026-02-14 19:43:55.497	demo-school
ec9aaddf-f52d-4173-a775-e1f542dd6e40	12	grade	sub_math	2026-02-14 19:43:55.497	demo-school
04f278fe-0e8e-4de1-b8a9-b1349757d96f	12	grade	sub_arabic	2026-02-14 19:43:55.497	demo-school
0a876f5e-8d81-4adc-92c3-d5e418b85895	12	grade	sub_english	2026-02-14 19:43:55.497	demo-school
a10ee87d-503b-4285-99cd-2f0b20ae31d6	12	grade	13e66761-da74-4866-88e5-7d2fa588dc87	2026-02-14 19:43:55.497	demo-school
bb33555f-011b-44df-b413-5a5c2f9076e9	12	grade	052a07e9-7224-4531-b063-f841e349036c	2026-02-14 19:43:55.497	demo-school
34ebf116-1f05-4ba3-8c18-24d92bb0d9c2	4	grade	d99bd5ee-8e30-406a-99d1-97f6eb23d5e6	2026-02-14 19:53:54.222	nazareth-baptist
cb1e8ee2-d2b9-4033-adcd-d1d9673aba20	4	grade	79c96f2b-1b2b-4862-b069-782f84533050	2026-02-14 19:53:54.222	nazareth-baptist
854f59b6-5ce1-4bbe-8234-fc42000f47c5	4	grade	ab43c67a-611e-42b6-b493-40defb03f823	2026-02-14 19:53:54.222	nazareth-baptist
edbb1d4d-66cc-46b4-a2bd-b2e677ddace6	4	grade	84a2cd40-c8a1-4cef-a0f8-2bfdb568d2ea	2026-02-14 19:53:54.222	nazareth-baptist
64884f25-fae2-4e72-a9db-bb7827d8d2c5	4	grade	5d777c2f-79dd-4675-af7a-62f6c7049fe1	2026-02-14 19:53:54.222	nazareth-baptist
006d56cf-4f94-40ea-8dc1-0e86573a78c9	4	grade	878c91ad-7133-4ed4-8579-384a44490f76	2026-02-14 19:53:54.222	nazareth-baptist
55d61180-afb0-4bfe-99d6-2220e41e6028	4	grade	bba3b58c-9184-4d7a-a9ff-ac6e08ff38b9	2026-02-14 19:53:54.222	nazareth-baptist
d1d86816-a4b0-4608-9d40-117024754dbc	4	grade	2f445af3-684e-4bda-b5bf-8777d694bff7	2026-02-14 19:53:54.222	nazareth-baptist
f8bee6da-8618-4b07-9f05-85bddcee8c17	4	grade	61ff0c29-6e70-4328-8045-ea8cc2ec36a1	2026-02-14 19:53:54.222	nazareth-baptist
c47477eb-195a-46c0-94b1-fcf0ef1c95de	4	grade	d6929dbf-a85f-4570-a7b8-5d378018afb3	2026-02-14 19:53:54.222	nazareth-baptist
492e72d4-d1ed-4ec2-9567-90b3eb13bbbe	5	grade	d99bd5ee-8e30-406a-99d1-97f6eb23d5e6	2026-02-14 19:53:54.223	nazareth-baptist
2db77a0e-b0f6-4192-9aa0-264db09addc6	5	grade	79c96f2b-1b2b-4862-b069-782f84533050	2026-02-14 19:53:54.223	nazareth-baptist
2c80ab83-1de2-4633-933a-7347a9ccdec9	5	grade	ab43c67a-611e-42b6-b493-40defb03f823	2026-02-14 19:53:54.223	nazareth-baptist
b66fa310-eeff-4f2f-9916-fb62c071a922	5	grade	84a2cd40-c8a1-4cef-a0f8-2bfdb568d2ea	2026-02-14 19:53:54.223	nazareth-baptist
bac0a049-d8e7-4424-b935-5b9a30ede184	5	grade	5d777c2f-79dd-4675-af7a-62f6c7049fe1	2026-02-14 19:53:54.223	nazareth-baptist
552075d0-90ac-490b-ade4-ada19f4a1142	5	grade	878c91ad-7133-4ed4-8579-384a44490f76	2026-02-14 19:53:54.223	nazareth-baptist
8156f5ae-0f17-4df4-bac1-e53a76397e34	5	grade	bba3b58c-9184-4d7a-a9ff-ac6e08ff38b9	2026-02-14 19:53:54.223	nazareth-baptist
aa439684-2707-44b4-99e7-fd22252f08f0	5	grade	2f445af3-684e-4bda-b5bf-8777d694bff7	2026-02-14 19:53:54.223	nazareth-baptist
78e22856-c08b-43c0-a7b0-7606a5030e23	5	grade	61ff0c29-6e70-4328-8045-ea8cc2ec36a1	2026-02-14 19:53:54.223	nazareth-baptist
fc4d74c1-aeee-4551-a2f6-f5c4da2173ff	5	grade	8a2fd8a6-cb1b-4af4-83db-a27ab2e9cf54	2026-02-14 19:53:54.223	nazareth-baptist
c2356c2d-0353-4f2e-918d-5aadb5cf705a	5	grade	d6929dbf-a85f-4570-a7b8-5d378018afb3	2026-02-14 19:53:54.223	nazareth-baptist
488ab236-3e5d-4e71-9332-0b823963c280	6	grade	d99bd5ee-8e30-406a-99d1-97f6eb23d5e6	2026-02-14 19:53:54.224	nazareth-baptist
f2e0fa28-0d70-43e2-8cf6-1a24d83cbc0d	6	grade	79c96f2b-1b2b-4862-b069-782f84533050	2026-02-14 19:53:54.224	nazareth-baptist
66b89955-9e1e-47e8-bbb0-9aa01308b8f8	6	grade	ab43c67a-611e-42b6-b493-40defb03f823	2026-02-14 19:53:54.224	nazareth-baptist
61457ac2-de95-4969-969a-d305a4a6f570	6	grade	84a2cd40-c8a1-4cef-a0f8-2bfdb568d2ea	2026-02-14 19:53:54.224	nazareth-baptist
23a1ff0f-eb5c-4a7e-8475-cff589e9e6ae	6	grade	5d777c2f-79dd-4675-af7a-62f6c7049fe1	2026-02-14 19:53:54.224	nazareth-baptist
ba1496bf-6f05-44fe-8e7e-5d9ef09454c9	6	grade	878c91ad-7133-4ed4-8579-384a44490f76	2026-02-14 19:53:54.224	nazareth-baptist
ca426cc7-ebd9-43a1-bf52-c7ed0bdb9bac	6	grade	bba3b58c-9184-4d7a-a9ff-ac6e08ff38b9	2026-02-14 19:53:54.224	nazareth-baptist
9f0510f1-d058-4ba2-9530-7a7efb2c0f14	6	grade	2f445af3-684e-4bda-b5bf-8777d694bff7	2026-02-14 19:53:54.224	nazareth-baptist
dbdacafc-6f40-42f2-bdf5-4f1ec6fd824a	6	grade	61ff0c29-6e70-4328-8045-ea8cc2ec36a1	2026-02-14 19:53:54.224	nazareth-baptist
e9b14d5a-c22c-478c-88e2-efb08c422156	6	grade	d6929dbf-a85f-4570-a7b8-5d378018afb3	2026-02-14 19:53:54.224	nazareth-baptist
2f67c3b3-12f2-4e1d-9175-538658a27e22	7	grade	d99bd5ee-8e30-406a-99d1-97f6eb23d5e6	2026-02-14 19:53:54.224	nazareth-baptist
55e21232-3ec9-492d-9fda-d754df8a4ab7	7	grade	79c96f2b-1b2b-4862-b069-782f84533050	2026-02-14 19:53:54.224	nazareth-baptist
b1a7392e-5908-4ef7-8f79-db0ade81157d	7	grade	ab43c67a-611e-42b6-b493-40defb03f823	2026-02-14 19:53:54.224	nazareth-baptist
78a7bdb5-5fe2-40af-adc4-9e9a119c58f1	7	grade	84a2cd40-c8a1-4cef-a0f8-2bfdb568d2ea	2026-02-14 19:53:54.224	nazareth-baptist
f1701c92-5e45-4edf-9b1e-81541589d394	7	grade	5d777c2f-79dd-4675-af7a-62f6c7049fe1	2026-02-14 19:53:54.224	nazareth-baptist
16377265-3a7c-4322-bce5-363dc5d94e34	7	grade	878c91ad-7133-4ed4-8579-384a44490f76	2026-02-14 19:53:54.224	nazareth-baptist
14ea1dfe-8846-43b7-be20-466acfee6892	7	grade	bba3b58c-9184-4d7a-a9ff-ac6e08ff38b9	2026-02-14 19:53:54.224	nazareth-baptist
4490e0ac-4414-4613-8ffa-a590abda917d	7	grade	2f445af3-684e-4bda-b5bf-8777d694bff7	2026-02-14 19:53:54.224	nazareth-baptist
103ea019-907c-4f5c-9b6c-35a778d44c54	7	grade	5b074a0d-2616-45d7-979f-0b9f43fb468e	2026-02-14 19:53:54.224	nazareth-baptist
75b91997-36af-49e8-93da-604ff0f0b769	7	grade	61ff0c29-6e70-4328-8045-ea8cc2ec36a1	2026-02-14 19:53:54.224	nazareth-baptist
0da404b5-f2d2-4b09-9c4d-387e6a8c70e8	7	grade	6957fe92-bafa-4ce7-88b2-3ef92df237e5	2026-02-14 19:53:54.224	nazareth-baptist
2c483695-ef77-430e-b6ec-0d6d2c460cf6	7	grade	d50c900c-617c-4e0a-a384-f936a47c9846	2026-02-14 19:53:54.224	nazareth-baptist
4e634c21-5a36-4fc7-ae07-01f47f5e8895	7	grade	211f94bf-9aae-4edc-83b8-5f5f63e54ef7	2026-02-14 19:53:54.224	nazareth-baptist
1a6bb616-d7bd-4944-8912-0140d5b13b80	8	grade	d99bd5ee-8e30-406a-99d1-97f6eb23d5e6	2026-02-14 19:53:54.225	nazareth-baptist
6bec8d96-2ec5-42b2-98d1-5eda48a23bb4	8	grade	79c96f2b-1b2b-4862-b069-782f84533050	2026-02-14 19:53:54.225	nazareth-baptist
657e2373-b8c3-469f-b224-343c7d58cd76	8	grade	ab43c67a-611e-42b6-b493-40defb03f823	2026-02-14 19:53:54.225	nazareth-baptist
01ddc0c8-d1e1-4f42-860e-0680769e5cdf	8	grade	84a2cd40-c8a1-4cef-a0f8-2bfdb568d2ea	2026-02-14 19:53:54.225	nazareth-baptist
0a5ae193-00e3-420c-9b18-0c1763501a70	8	grade	5d777c2f-79dd-4675-af7a-62f6c7049fe1	2026-02-14 19:53:54.225	nazareth-baptist
a9471a41-c2ab-438a-a997-dca0c0b1c14d	8	grade	878c91ad-7133-4ed4-8579-384a44490f76	2026-02-14 19:53:54.225	nazareth-baptist
02d4ed28-5d51-449f-9adc-4b190434fa60	8	grade	bba3b58c-9184-4d7a-a9ff-ac6e08ff38b9	2026-02-14 19:53:54.225	nazareth-baptist
8904c9c7-f700-4b3e-a6e9-22aeb3f8e7e1	8	grade	2f445af3-684e-4bda-b5bf-8777d694bff7	2026-02-14 19:53:54.225	nazareth-baptist
9eb653a0-4220-44aa-83f7-fa4ab37e6c04	8	grade	5b074a0d-2616-45d7-979f-0b9f43fb468e	2026-02-14 19:53:54.225	nazareth-baptist
1cf74ea7-ad83-498c-9ed3-ba22f7abda97	8	grade	61ff0c29-6e70-4328-8045-ea8cc2ec36a1	2026-02-14 19:53:54.225	nazareth-baptist
a78ea0de-4333-4e11-9828-1462f0d140e8	8	grade	6957fe92-bafa-4ce7-88b2-3ef92df237e5	2026-02-14 19:53:54.225	nazareth-baptist
34876a8b-67fb-480c-b1ac-376ec9aef490	8	grade	d50c900c-617c-4e0a-a384-f936a47c9846	2026-02-14 19:53:54.225	nazareth-baptist
6c184535-e2df-47f6-9c4f-b161a6681ffb	8	grade	211f94bf-9aae-4edc-83b8-5f5f63e54ef7	2026-02-14 19:53:54.225	nazareth-baptist
5e368087-18a2-4587-8d6f-eabab3c60d9a	8	grade	312fbc07-060f-4b54-a5b2-26cce9d83e65	2026-02-14 19:53:54.225	nazareth-baptist
984509ab-9645-41d4-b69d-a214a282b836	9	grade	d99bd5ee-8e30-406a-99d1-97f6eb23d5e6	2026-02-14 19:53:54.225	nazareth-baptist
c386a4ed-8fa5-4d1b-a1af-a8f12f112608	9	grade	79c96f2b-1b2b-4862-b069-782f84533050	2026-02-14 19:53:54.225	nazareth-baptist
fab29e75-0ee2-4880-99c5-f9cab099b6f6	9	grade	ab43c67a-611e-42b6-b493-40defb03f823	2026-02-14 19:53:54.225	nazareth-baptist
88643727-71dc-4b57-94f1-252fb80aedb1	9	grade	84a2cd40-c8a1-4cef-a0f8-2bfdb568d2ea	2026-02-14 19:53:54.225	nazareth-baptist
68a2cb8b-4f47-4c47-b59d-13566fe3a83c	9	grade	5d777c2f-79dd-4675-af7a-62f6c7049fe1	2026-02-14 19:53:54.225	nazareth-baptist
3015b399-dfc6-42f6-8d16-74c7a0df7c76	9	grade	878c91ad-7133-4ed4-8579-384a44490f76	2026-02-14 19:53:54.225	nazareth-baptist
00a30592-00ca-4255-b8f3-7d2e62248fc8	9	grade	bba3b58c-9184-4d7a-a9ff-ac6e08ff38b9	2026-02-14 19:53:54.225	nazareth-baptist
f09e1f4c-b546-4f63-80c5-69ceeeff2d9b	9	grade	2f445af3-684e-4bda-b5bf-8777d694bff7	2026-02-14 19:53:54.225	nazareth-baptist
8c7007b3-c8fc-44e3-aa59-a8d2127ed58a	9	grade	5b074a0d-2616-45d7-979f-0b9f43fb468e	2026-02-14 19:53:54.225	nazareth-baptist
97915380-0904-4dfb-8abe-5ae2e034c4b8	9	grade	6957fe92-bafa-4ce7-88b2-3ef92df237e5	2026-02-14 19:53:54.225	nazareth-baptist
ce50c095-d235-4a9c-a53e-280ec1c83cb2	9	grade	d50c900c-617c-4e0a-a384-f936a47c9846	2026-02-14 19:53:54.225	nazareth-baptist
2c81b70d-fbcd-4a4d-b5f7-f3d0ea295c34	9	grade	aefc8b09-6ed6-4143-8743-fed95a91a89c	2026-02-14 19:53:54.225	nazareth-baptist
709cc4c0-72c4-489f-b02b-89d43d53bbde	9	grade	211f94bf-9aae-4edc-83b8-5f5f63e54ef7	2026-02-14 19:53:54.225	nazareth-baptist
19d2e7b0-f4a6-428f-ba2f-316caae2ae24	9	grade	8a2fd8a6-cb1b-4af4-83db-a27ab2e9cf54	2026-02-14 19:53:54.225	nazareth-baptist
0a87af29-da5f-43c8-ba7b-f4cbd60522c7	10	grade	d99bd5ee-8e30-406a-99d1-97f6eb23d5e6	2026-02-14 19:53:54.226	nazareth-baptist
6f54f0f0-8a7d-4c89-ad3e-96e91c3d7839	10	grade	79c96f2b-1b2b-4862-b069-782f84533050	2026-02-14 19:53:54.226	nazareth-baptist
678d99b1-76dc-457c-9924-eb7bf106eb88	10	grade	ab43c67a-611e-42b6-b493-40defb03f823	2026-02-14 19:53:54.226	nazareth-baptist
35d41150-d30a-4c18-b9f7-aff2331992e5	10	grade	84a2cd40-c8a1-4cef-a0f8-2bfdb568d2ea	2026-02-14 19:53:54.226	nazareth-baptist
b1651aec-d2e1-4e3f-852a-7632ffd18ed9	10	grade	5d777c2f-79dd-4675-af7a-62f6c7049fe1	2026-02-14 19:53:54.226	nazareth-baptist
494bc4b6-20ec-43fc-bb6e-34a2e88d8afa	10	grade	878c91ad-7133-4ed4-8579-384a44490f76	2026-02-14 19:53:54.226	nazareth-baptist
fb070c0a-07df-489f-a4ec-8cf27ae356da	10	grade	bba3b58c-9184-4d7a-a9ff-ac6e08ff38b9	2026-02-14 19:53:54.226	nazareth-baptist
82e093cc-3d85-4094-8397-37dc2b45b9af	10	grade	2f445af3-684e-4bda-b5bf-8777d694bff7	2026-02-14 19:53:54.226	nazareth-baptist
812a1855-bc33-467a-9bf2-8ea24c3be614	10	grade	5b074a0d-2616-45d7-979f-0b9f43fb468e	2026-02-14 19:53:54.226	nazareth-baptist
45ef6ab4-26a5-4c24-9030-4e8b2e4b68fc	10	grade	bf74d5e3-8880-4044-bc5d-59c76e795b0a	2026-02-14 19:53:54.226	nazareth-baptist
c4e1821a-d90b-41b9-9ccb-39dfbd04f35e	11	grade	d99bd5ee-8e30-406a-99d1-97f6eb23d5e6	2026-02-14 19:53:54.226	nazareth-baptist
e00082c3-855a-4895-8267-71209a9bb297	11	grade	79c96f2b-1b2b-4862-b069-782f84533050	2026-02-14 19:53:54.226	nazareth-baptist
810e37d8-b572-4d7c-9b93-75e26e0c9cd7	11	grade	ab43c67a-611e-42b6-b493-40defb03f823	2026-02-14 19:53:54.226	nazareth-baptist
9653be61-7210-48bf-9997-b06d55c9b9f1	11	grade	84a2cd40-c8a1-4cef-a0f8-2bfdb568d2ea	2026-02-14 19:53:54.226	nazareth-baptist
87da5203-5e5a-42ea-90f9-a90ba716d869	11	grade	5d777c2f-79dd-4675-af7a-62f6c7049fe1	2026-02-14 19:53:54.226	nazareth-baptist
c2ab6295-77b3-4434-bbaf-2160a84a019c	11	grade	878c91ad-7133-4ed4-8579-384a44490f76	2026-02-14 19:53:54.226	nazareth-baptist
7dd3c9f8-3f08-4839-8c87-588d774d668b	11	grade	bba3b58c-9184-4d7a-a9ff-ac6e08ff38b9	2026-02-14 19:53:54.226	nazareth-baptist
70e43767-03d3-44f9-b992-ea81877ea00d	11	grade	2f445af3-684e-4bda-b5bf-8777d694bff7	2026-02-14 19:53:54.226	nazareth-baptist
3fd20ee8-3b42-49aa-a4c4-7d70754ac8fb	11	grade	5b074a0d-2616-45d7-979f-0b9f43fb468e	2026-02-14 19:53:54.226	nazareth-baptist
8c4ef0a1-118b-448d-8791-55a3cc4d5973	12	grade	d99bd5ee-8e30-406a-99d1-97f6eb23d5e6	2026-02-14 19:53:54.226	nazareth-baptist
f5a182a7-1d07-45ff-81fb-d16fbf5262c3	12	grade	79c96f2b-1b2b-4862-b069-782f84533050	2026-02-14 19:53:54.226	nazareth-baptist
a076cdbd-f2c8-40ad-b64a-5548b16b9421	12	grade	ab43c67a-611e-42b6-b493-40defb03f823	2026-02-14 19:53:54.226	nazareth-baptist
a79c5c53-7b11-4b37-85ab-d695dbd14d7d	12	grade	84a2cd40-c8a1-4cef-a0f8-2bfdb568d2ea	2026-02-14 19:53:54.226	nazareth-baptist
a43bc7e8-163e-4eef-aa55-be7b6bd5be3c	12	grade	5d777c2f-79dd-4675-af7a-62f6c7049fe1	2026-02-14 19:53:54.226	nazareth-baptist
3fb734b4-8e72-4315-9907-881bbe29c4e4	12	grade	878c91ad-7133-4ed4-8579-384a44490f76	2026-02-14 19:53:54.226	nazareth-baptist
93332575-c8b1-474f-ac59-7c2ba83dd875	12	grade	bba3b58c-9184-4d7a-a9ff-ac6e08ff38b9	2026-02-14 19:53:54.226	nazareth-baptist
485cbc11-f91d-4ecf-8b82-b3508ee4bb81	12	grade	2f445af3-684e-4bda-b5bf-8777d694bff7	2026-02-14 19:53:54.226	nazareth-baptist
3f12414e-6c3d-4bf8-bc9b-bbc3439bbdb2	12	grade	5b074a0d-2616-45d7-979f-0b9f43fb468e	2026-02-14 19:53:54.226	nazareth-baptist
\.


--
-- Data for Name: Major; Type: TABLE DATA; Schema: public; Owner: classmate
--

COPY public."Major" (id, "schoolId", name, type) FROM stdin;
e8657199-786c-4a71-95dc-f72134cfe48f	demo-school	Electronics	technological
4efdfc75-04fe-4098-88ac-f177bf23c776	demo-school	Physics	scientific
2d46d76e-ce8e-4b9a-a024-bb50a6898c4f	nazareth-baptist	Electronics	technological
f611053a-ac72-4bd9-a834-9b93e10a11c4	nazareth-baptist	Physics	scientific
\.


--
-- Data for Name: MajorSubject; Type: TABLE DATA; Schema: public; Owner: classmate
--

COPY public."MajorSubject" (id, "schoolId", "majorId", "subjectId") FROM stdin;
8bfc3c77-9819-4190-b972-832d0687a2f1	demo-school	e8657199-786c-4a71-95dc-f72134cfe48f	sub_electronics
21feb3e6-a46e-4923-831b-5555e43b4a19	demo-school	4efdfc75-04fe-4098-88ac-f177bf23c776	sub_physics
a871402d-4126-4b09-8f01-b1baaf72e670	nazareth-baptist	f611053a-ac72-4bd9-a834-9b93e10a11c4	aefc8b09-6ed6-4143-8743-fed95a91a89c
cmlmrut280000jv01el0vz50u	nazareth-baptist	2d46d76e-ce8e-4b9a-a024-bb50a6898c4f	211f94bf-9aae-4edc-83b8-5f5f63e54ef7
cmlmrut280001jv011n1nvh8h	nazareth-baptist	2d46d76e-ce8e-4b9a-a024-bb50a6898c4f	312fbc07-060f-4b54-a5b2-26cce9d83e65
\.


--
-- Data for Name: Message; Type: TABLE DATA; Schema: public; Owner: classmate
--

COPY public."Message" (id, "classroomId", "userId", kind, text, "mediaUrl", "createdAt") FROM stdin;
\.


--
-- Data for Name: Notification; Type: TABLE DATA; Schema: public; Owner: classmate
--

COPY public."Notification" (id, "userId", kind, title, body, "seenAt", "createdAt") FROM stdin;
\.


--
-- Data for Name: Role; Type: TABLE DATA; Schema: public; Owner: classmate
--

COPY public."Role" (id, name) FROM stdin;
role_admin	admin
role_teacher	teacher
role_student	student
\.


--
-- Data for Name: ScheduleEntry; Type: TABLE DATA; Schema: public; Owner: classmate
--

COPY public."ScheduleEntry" (id, "userId", "subjectId", "startAt", "endAt", room, teacher, "createdAt", "classroomId", "schoolId") FROM stdin;
cmlnnluch0003pc0140em4rvp	\N	ab43c67a-611e-42b6-b493-40defb03f823	2026-02-15 07:30:00	2026-02-15 08:15:00	B12	Ms. Lina	2026-02-15 11:20:11.489	cmlmqix4l001iqj01uvkwp585	nazareth-baptist
\.


--
-- Data for Name: School; Type: TABLE DATA; Schema: public; Owner: classmate
--

COPY public."School" (id, name) FROM stdin;
demo-school	demo-school
nazareth-baptist	Nazareth Baptist School
\.


--
-- Data for Name: Solution; Type: TABLE DATA; Schema: public; Owner: classmate
--

COPY public."Solution" (id, "userId", "subjectId", grade, book, page, question, caption, "mediaUrl", "createdAt", "classroomId", "schoolId") FROM stdin;
cmlo622vj0001nz01bnd4uhxp	cmlms1ao20003jv01zyhz4ej1	ab43c67a-611e-42b6-b493-40defb03f823	10	Bagrut Arabic	12	Q1	demo	https://example.com/demo.png	2026-02-15 19:56:42.127	cmlmr8htm000moo01lgtt7b8r	nazareth-baptist
cmlp0oxeq0001o7017lzimmbf	cmlms1ao20003jv01zyhz4ej1	ab43c67a-611e-42b6-b493-40defb03f823	10	Bagrut Arabic	12	Q_LOCK_TEST	lock smoke	https://example.com/demo.png	2026-02-16 10:14:16.61	cmlmr8htm000moo01lgtt7b8r	nazareth-baptist
cmlp0y5420003o70126imb1dx	cmlms1ao20003jv01zyhz4ej1	ab43c67a-611e-42b6-b493-40defb03f823	10	Bagrut Arabic	99	STRICT_LOCK_TEST	strict lock	https://example.com/strict.png	2026-02-16 10:21:26.498	cmlmr8htm000moo01lgtt7b8r	nazareth-baptist
\.


--
-- Data for Name: SolutionComment; Type: TABLE DATA; Schema: public; Owner: classmate
--

COPY public."SolutionComment" (id, "solutionId", "userId", text, "createdAt") FROM stdin;
\.


--
-- Data for Name: SolutionLike; Type: TABLE DATA; Schema: public; Owner: classmate
--

COPY public."SolutionLike" (id, "solutionId", "userId", "createdAt") FROM stdin;
cmlp1pz0k0001pa01foalke8q	cmlp0y5420003o70126imb1dx	cmlmr8hte0001oo01xhbsm3r6	2026-02-16 10:43:04.964
\.


--
-- Data for Name: StudentSubject; Type: TABLE DATA; Schema: public; Owner: classmate
--

COPY public."StudentSubject" (id, "userId", "subjectId", source, "createdAt", "schoolId") FROM stdin;
cmlld20zh0002sc01n4l8e7zq	cmlld20ze0001sc0183k3uvtd	sub_arabic	core	2026-02-13 20:49:18.462	demo-school
cmlld20zh0003sc01pqohhxul	cmlld20ze0001sc0183k3uvtd	sub_hebrew	core	2026-02-13 20:49:18.462	demo-school
cmlld20zh0004sc010tur7avk	cmlld20ze0001sc0183k3uvtd	sub_pe	core	2026-02-13 20:49:18.462	demo-school
cmlld20zh0005sc01j437p4d8	cmlld20ze0001sc0183k3uvtd	sub_religion	core	2026-02-13 20:49:18.462	demo-school
cmlld20zh0006sc01ue3ub5sd	cmlld20ze0001sc0183k3uvtd	sub_chapel	core	2026-02-13 20:49:18.462	demo-school
cmlld20zh0007sc01h1ou2vwt	cmlld20ze0001sc0183k3uvtd	sub_english	grade	2026-02-13 20:49:18.462	demo-school
cmlld20zh0008sc01p490w2ro	cmlld20ze0001sc0183k3uvtd	sub_math	grade	2026-02-13 20:49:18.462	demo-school
cmlld20zh0009sc01vzhpv19m	cmlld20ze0001sc0183k3uvtd	sub_physics	major	2026-02-13 20:49:18.462	demo-school
cmlld20zh000asc01wombn1k6	cmlld20ze0001sc0183k3uvtd	sub_computer_science	grade	2026-02-13 20:49:18.462	demo-school
cmlld84a30002ny01xi8ljgxb	cmlld849z0001ny01nt0z34dd	sub_arabic	core	2026-02-13 20:54:02.667	demo-school
cmlld84a30003ny018s1d95zb	cmlld849z0001ny01nt0z34dd	sub_hebrew	core	2026-02-13 20:54:02.667	demo-school
cmlld84a30004ny01l2obeu7n	cmlld849z0001ny01nt0z34dd	sub_pe	core	2026-02-13 20:54:02.667	demo-school
cmlld84a30005ny017prmxfdh	cmlld849z0001ny01nt0z34dd	sub_religion	core	2026-02-13 20:54:02.667	demo-school
cmlld84a30006ny01icysa6z9	cmlld849z0001ny01nt0z34dd	sub_chapel	core	2026-02-13 20:54:02.667	demo-school
cmlld84a30007ny01epww4lll	cmlld849z0001ny01nt0z34dd	sub_english	grade	2026-02-13 20:54:02.667	demo-school
cmlld84a30008ny01ljpurwr5	cmlld849z0001ny01nt0z34dd	sub_math	grade	2026-02-13 20:54:02.667	demo-school
cmlld84a30009ny01x8ppmora	cmlld849z0001ny01nt0z34dd	sub_physics	grade	2026-02-13 20:54:02.667	demo-school
cmlld84a3000any01s6frg3gs	cmlld849z0001ny01nt0z34dd	sub_computer_science	grade	2026-02-13 20:54:02.667	demo-school
cmlldtgse000mny01urno9vrd	cmlldtgsb000lny011fa2m00w	sub_arabic	core	2026-02-13 21:10:38.654	demo-school
cmlldtgse000nny01l9e4uy6b	cmlldtgsb000lny011fa2m00w	sub_hebrew	core	2026-02-13 21:10:38.654	demo-school
cmlldtgse000ony01hmh9al63	cmlldtgsb000lny011fa2m00w	sub_pe	core	2026-02-13 21:10:38.654	demo-school
cmlldtgse000pny01y2i8ng8b	cmlldtgsb000lny011fa2m00w	sub_religion	core	2026-02-13 21:10:38.654	demo-school
cmlldtgse000qny01tpwjpixw	cmlldtgsb000lny011fa2m00w	sub_chapel	core	2026-02-13 21:10:38.654	demo-school
cmlldtgse000rny01id0qfqku	cmlldtgsb000lny011fa2m00w	sub_english	grade	2026-02-13 21:10:38.654	demo-school
cmlldtgse000sny01q5a56xev	cmlldtgsb000lny011fa2m00w	sub_math	grade	2026-02-13 21:10:38.654	demo-school
cmlldtgse000tny01rx5yw8s0	cmlldtgsb000lny011fa2m00w	sub_physics	grade	2026-02-13 21:10:38.654	demo-school
cmlldtgse000uny011fy31ejn	cmlldtgsb000lny011fa2m00w	sub_computer_science	grade	2026-02-13 21:10:38.654	demo-school
cmlmfts1k0002pf01mhxr0eaw	cmlmfts1g0001pf01gdjhr7u3	sub_arabic	core	2026-02-14 14:54:38.649	demo-school
cmlmfts1k0003pf01ckyq09fh	cmlmfts1g0001pf01gdjhr7u3	sub_hebrew	core	2026-02-14 14:54:38.649	demo-school
cmlmfts1k0004pf011slg2qa6	cmlmfts1g0001pf01gdjhr7u3	sub_pe	core	2026-02-14 14:54:38.649	demo-school
cmlmfts1k0005pf01el43kj3x	cmlmfts1g0001pf01gdjhr7u3	sub_religion	core	2026-02-14 14:54:38.649	demo-school
cmlmfts1k0006pf01hc1zu95l	cmlmfts1g0001pf01gdjhr7u3	sub_chapel	core	2026-02-14 14:54:38.649	demo-school
cmlmfts1k0007pf01v2a76xir	cmlmfts1g0001pf01gdjhr7u3	sub_english	grade	2026-02-14 14:54:38.649	demo-school
cmlmfts1k0008pf01x37ls0mf	cmlmfts1g0001pf01gdjhr7u3	sub_math	grade	2026-02-14 14:54:38.649	demo-school
cmlmfts1k0009pf013xnr8epy	cmlmfts1g0001pf01gdjhr7u3	sub_physics	grade	2026-02-14 14:54:38.649	demo-school
cmlmfts1k000apf017zaghooq	cmlmfts1g0001pf01gdjhr7u3	sub_computer_science	grade	2026-02-14 14:54:38.649	demo-school
cmlmfzbna000mpf019wk7h68r	cmlmfzbn7000lpf01zzglwtgg	sub_arabic	core	2026-02-14 14:58:57.334	demo-school
cmlmfzbna000npf01ci6gsmz9	cmlmfzbn7000lpf01zzglwtgg	sub_hebrew	core	2026-02-14 14:58:57.334	demo-school
cmlmfzbna000opf017x7bop89	cmlmfzbn7000lpf01zzglwtgg	sub_pe	core	2026-02-14 14:58:57.334	demo-school
cmlmfzbna000ppf01x0zt5xtj	cmlmfzbn7000lpf01zzglwtgg	sub_religion	core	2026-02-14 14:58:57.334	demo-school
cmlmfzbna000qpf01ig32wliq	cmlmfzbn7000lpf01zzglwtgg	sub_chapel	core	2026-02-14 14:58:57.334	demo-school
cmlmfzbna000rpf013u8559m5	cmlmfzbn7000lpf01zzglwtgg	sub_math	grade	2026-02-14 14:58:57.334	demo-school
cmlmfzbna000spf01yzfg9znc	cmlmfzbn7000lpf01zzglwtgg	sub_chemistry	grade	2026-02-14 14:58:57.334	demo-school
cmlmfzbna000tpf01m759cwlz	cmlmfzbn7000lpf01zzglwtgg	sub_biology	grade	2026-02-14 14:58:57.334	demo-school
cmlmfzbna000upf01hprgjqpr	cmlmfzbn7000lpf01zzglwtgg	sub_electronics	grade	2026-02-14 14:58:57.334	demo-school
cmlmgqd4o001opf01r58n1tfw	cmlmgqd4l001npf010agnz6ck	sub_arabic	core	2026-02-14 15:19:58.969	demo-school
cmlmgqd4o001ppf01mfa1pojm	cmlmgqd4l001npf010agnz6ck	sub_hebrew	core	2026-02-14 15:19:58.969	demo-school
cmlmgqd4p001qpf01deomx6hd	cmlmgqd4l001npf010agnz6ck	sub_pe	core	2026-02-14 15:19:58.969	demo-school
cmlmgqd4p001rpf01axne5hp5	cmlmgqd4l001npf010agnz6ck	sub_religion	core	2026-02-14 15:19:58.969	demo-school
cmlmgqd4p001spf01e5jca8zs	cmlmgqd4l001npf010agnz6ck	sub_chapel	core	2026-02-14 15:19:58.969	demo-school
cmlmgqd4p001tpf01xilyfhyi	cmlmgqd4l001npf010agnz6ck	sub_english	grade	2026-02-14 15:19:58.969	demo-school
cmlmgqd4p001upf01z14o4czd	cmlmgqd4l001npf010agnz6ck	sub_math	grade	2026-02-14 15:19:58.969	demo-school
cmlmgqd4p001vpf01wrllo0pc	cmlmgqd4l001npf010agnz6ck	sub_physics	grade	2026-02-14 15:19:58.969	demo-school
cmlmgqd4p001wpf01n9gkb2u8	cmlmgqd4l001npf010agnz6ck	sub_computer_science	grade	2026-02-14 15:19:58.969	demo-school
cmlmhk3hk0028pf01t7dhybex	cmlmhk3hg0027pf01cwt0fupx	sub_arabic	core	2026-02-14 15:43:06.153	demo-school
cmlmhk3hk0029pf01gj3w9y16	cmlmhk3hg0027pf01cwt0fupx	sub_hebrew	core	2026-02-14 15:43:06.153	demo-school
cmlmhk3hk002apf01l6una8cy	cmlmhk3hg0027pf01cwt0fupx	sub_pe	core	2026-02-14 15:43:06.153	demo-school
cmlmhk3hk002bpf01ndneubqm	cmlmhk3hg0027pf01cwt0fupx	sub_religion	core	2026-02-14 15:43:06.153	demo-school
cmlmhk3hk002cpf017bp7hwag	cmlmhk3hg0027pf01cwt0fupx	sub_chapel	core	2026-02-14 15:43:06.153	demo-school
cmlmhk3hk002dpf01bwhtss1c	cmlmhk3hg0027pf01cwt0fupx	sub_math	grade	2026-02-14 15:43:06.153	demo-school
cmlmhk3hk002epf01xp9dhmcv	cmlmhk3hg0027pf01cwt0fupx	sub_chemistry	grade	2026-02-14 15:43:06.153	demo-school
cmlmhk3hk002fpf01w8suxqls	cmlmhk3hg0027pf01cwt0fupx	sub_biology	grade	2026-02-14 15:43:06.153	demo-school
cmlmhk3hk002gpf01vq8hj4ue	cmlmhk3hg0027pf01cwt0fupx	sub_electronics	grade	2026-02-14 15:43:06.153	demo-school
cmlmhpjty002spf01g6hr2bh4	cmlmhpjtw002rpf01dswhe3mn	sub_arabic	core	2026-02-14 15:47:20.615	demo-school
cmlmhpjty002tpf01zn16mj5e	cmlmhpjtw002rpf01dswhe3mn	sub_hebrew	core	2026-02-14 15:47:20.615	demo-school
cmlmhpjty002upf01ysjspmm8	cmlmhpjtw002rpf01dswhe3mn	sub_pe	core	2026-02-14 15:47:20.615	demo-school
cmlmhpjty002vpf01l29b53ih	cmlmhpjtw002rpf01dswhe3mn	sub_religion	core	2026-02-14 15:47:20.615	demo-school
cmlmhpjty002wpf01g2dhk9zj	cmlmhpjtw002rpf01dswhe3mn	sub_chapel	core	2026-02-14 15:47:20.615	demo-school
cmlmhpjty002xpf01r8ilimce	cmlmhpjtw002rpf01dswhe3mn	sub_english	grade	2026-02-14 15:47:20.615	demo-school
cmlmhpjty002ypf01yvgb2fte	cmlmhpjtw002rpf01dswhe3mn	sub_math	grade	2026-02-14 15:47:20.615	demo-school
cmlmi3fuo0038pf019wshugos	cmlmi3ful0037pf01mlb614dc	sub_arabic	core	2026-02-14 15:58:08.64	demo-school
cmlmi3fuo0039pf01ldazpdue	cmlmi3ful0037pf01mlb614dc	sub_hebrew	core	2026-02-14 15:58:08.64	demo-school
cmlmi3fuo003apf01aoowpmxy	cmlmi3ful0037pf01mlb614dc	sub_pe	core	2026-02-14 15:58:08.64	demo-school
cmlmi3fuo003bpf01a43s4qhb	cmlmi3ful0037pf01mlb614dc	sub_religion	core	2026-02-14 15:58:08.64	demo-school
cmlmi3fuo003cpf01o7428ed0	cmlmi3ful0037pf01mlb614dc	sub_chapel	core	2026-02-14 15:58:08.64	demo-school
cmlmi3fuo003dpf016u882279	cmlmi3ful0037pf01mlb614dc	sub_english	grade	2026-02-14 15:58:08.64	demo-school
cmlmi3fuo003epf01wp6czyku	cmlmi3ful0037pf01mlb614dc	sub_math	grade	2026-02-14 15:58:08.64	demo-school
cmlmi8igi003opf01782amh6l	cmlmi8ige003npf01bbc9gwgy	sub_arabic	core	2026-02-14 16:02:05.298	demo-school
cmlmi8igi003ppf01lh2h69bm	cmlmi8ige003npf01bbc9gwgy	sub_hebrew	core	2026-02-14 16:02:05.298	demo-school
cmlmi8igi003qpf01qdhur7ai	cmlmi8ige003npf01bbc9gwgy	sub_pe	core	2026-02-14 16:02:05.298	demo-school
cmlmi8igi003rpf0108cj8rw4	cmlmi8ige003npf01bbc9gwgy	sub_religion	core	2026-02-14 16:02:05.298	demo-school
cmlmi8igi003spf01a6t9wgey	cmlmi8ige003npf01bbc9gwgy	sub_chapel	core	2026-02-14 16:02:05.298	demo-school
cmlmi8igi003tpf0142u36i2e	cmlmi8ige003npf01bbc9gwgy	sub_english	grade	2026-02-14 16:02:05.298	demo-school
cmlmi8igi003upf01x2az7z05	cmlmi8ige003npf01bbc9gwgy	sub_math	grade	2026-02-14 16:02:05.298	demo-school
cmlmi8igi003vpf0128p3wewq	cmlmi8ige003npf01bbc9gwgy	sub_physics	major	2026-02-14 16:02:05.298	demo-school
cmlmi956q0046pf01fogymm88	cmlmi956o0045pf01quuhuv2g	sub_arabic	core	2026-02-14 16:02:34.755	demo-school
cmlmi956q0047pf010j12zs7z	cmlmi956o0045pf01quuhuv2g	sub_hebrew	core	2026-02-14 16:02:34.755	demo-school
cmlmi956q0048pf01qb6982ya	cmlmi956o0045pf01quuhuv2g	sub_pe	core	2026-02-14 16:02:34.755	demo-school
cmlmi956q0049pf017yy3qyrj	cmlmi956o0045pf01quuhuv2g	sub_religion	core	2026-02-14 16:02:34.755	demo-school
cmlmi956q004apf01u8zyj413	cmlmi956o0045pf01quuhuv2g	sub_chapel	core	2026-02-14 16:02:34.755	demo-school
cmlmi956q004bpf011m8qpmi4	cmlmi956o0045pf01quuhuv2g	sub_english	grade	2026-02-14 16:02:34.755	demo-school
cmlmi956q004cpf01gnbzfnvw	cmlmi956o0045pf01quuhuv2g	sub_math	grade	2026-02-14 16:02:34.755	demo-school
cmlmi956q004dpf019aqq7d4t	cmlmi956o0045pf01quuhuv2g	sub_chemistry	major	2026-02-14 16:02:34.755	demo-school
cmlmi956q004epf01vji9lm6u	cmlmi956o0045pf01quuhuv2g	sub_electronics	major	2026-02-14 16:02:34.755	demo-school
cmlmm71kn0002li013uln8oqr	cmlmm71kj0001li0149ow96ih	sub_arabic	core	2026-02-14 17:52:55.223	demo-school
cmlmm71kn0003li01a0vubhi0	cmlmm71kj0001li0149ow96ih	sub_hebrew	core	2026-02-14 17:52:55.223	demo-school
cmlmm71kn0004li01nhqhnq5s	cmlmm71kj0001li0149ow96ih	sub_pe	core	2026-02-14 17:52:55.223	demo-school
cmlmm71kn0005li013fn7sbr2	cmlmm71kj0001li0149ow96ih	sub_religion	core	2026-02-14 17:52:55.223	demo-school
cmlmm71kn0006li01a8kr7s3u	cmlmm71kj0001li0149ow96ih	sub_chapel	core	2026-02-14 17:52:55.223	demo-school
cmlmm71kn0007li01i9irflnm	cmlmm71kj0001li0149ow96ih	sub_english	grade	2026-02-14 17:52:55.223	demo-school
cmlmm71kn0008li01wetf0pfp	cmlmm71kj0001li0149ow96ih	sub_math	grade	2026-02-14 17:52:55.223	demo-school
cmlmm71kn0009li01u2v81kh2	cmlmm71kj0001li0149ow96ih	sub_electronics	major	2026-02-14 17:52:55.223	demo-school
cmlmq65gz0002qj01ras83of7	cmlmq65gt0001qj01cygw4mly	sub_hebrew	grade	2026-02-14 19:44:12.083	demo-school
cmlmq65gz0003qj01wjvhip7v	cmlmq65gt0001qj01cygw4mly	sub_pe	grade	2026-02-14 19:44:12.083	demo-school
cmlmq65gz0004qj013mjk62c0	cmlmq65gt0001qj01cygw4mly	sub_religion	grade	2026-02-14 19:44:12.083	demo-school
cmlmq65gz0005qj01jgveq5va	cmlmq65gt0001qj01cygw4mly	sub_chapel	grade	2026-02-14 19:44:12.083	demo-school
cmlmq65gz0006qj01yorlwtzq	cmlmq65gt0001qj01cygw4mly	sub_math	grade	2026-02-14 19:44:12.083	demo-school
cmlmq65gz0007qj01hvmh6u0a	cmlmq65gt0001qj01cygw4mly	sub_arabic	grade	2026-02-14 19:44:12.083	demo-school
cmlmq65gz0008qj01iojo2l3q	cmlmq65gt0001qj01cygw4mly	sub_english	grade	2026-02-14 19:44:12.083	demo-school
cmlmq65gz0009qj016nkdzm8y	cmlmq65gt0001qj01cygw4mly	13e66761-da74-4866-88e5-7d2fa588dc87	grade	2026-02-14 19:44:12.083	demo-school
cmlmq65gz000aqj01j1eqzebq	cmlmq65gt0001qj01cygw4mly	052a07e9-7224-4531-b063-f841e349036c	grade	2026-02-14 19:44:12.083	demo-school
cmlmq65gz000bqj0195czlhuf	cmlmq65gt0001qj01cygw4mly	d3db3f9d-2269-4d5e-9ac5-5461d27d4531	grade	2026-02-14 19:44:12.083	demo-school
cmlmq65gz000cqj018bk13glx	cmlmq65gt0001qj01cygw4mly	sub_electronics	major	2026-02-14 19:44:12.083	demo-school
cmlmqix4g000wqj01drcmcmi5	cmlmqix4c000vqj01g91a2t82	84a2cd40-c8a1-4cef-a0f8-2bfdb568d2ea	grade	2026-02-14 19:54:07.793	nazareth-baptist
cmlmqix4g000xqj01o0i7vpj0	cmlmqix4c000vqj01g91a2t82	bba3b58c-9184-4d7a-a9ff-ac6e08ff38b9	grade	2026-02-14 19:54:07.793	nazareth-baptist
cmlmqix4g000yqj018ww4bafo	cmlmqix4c000vqj01g91a2t82	5d777c2f-79dd-4675-af7a-62f6c7049fe1	grade	2026-02-14 19:54:07.793	nazareth-baptist
cmlmqix4g000zqj01dsz5qp9g	cmlmqix4c000vqj01g91a2t82	878c91ad-7133-4ed4-8579-384a44490f76	grade	2026-02-14 19:54:07.793	nazareth-baptist
cmlmqix4g0010qj01k6dh53z4	cmlmqix4c000vqj01g91a2t82	d99bd5ee-8e30-406a-99d1-97f6eb23d5e6	grade	2026-02-14 19:54:07.793	nazareth-baptist
cmlmqix4g0011qj01vy11ayk1	cmlmqix4c000vqj01g91a2t82	ab43c67a-611e-42b6-b493-40defb03f823	grade	2026-02-14 19:54:07.793	nazareth-baptist
cmlmqix4g0012qj01z8y9f5u8	cmlmqix4c000vqj01g91a2t82	79c96f2b-1b2b-4862-b069-782f84533050	grade	2026-02-14 19:54:07.793	nazareth-baptist
cmlmqix4g0013qj01x0wyio5g	cmlmqix4c000vqj01g91a2t82	2f445af3-684e-4bda-b5bf-8777d694bff7	grade	2026-02-14 19:54:07.793	nazareth-baptist
cmlmqix4g0014qj01hnfp2kpw	cmlmqix4c000vqj01g91a2t82	5b074a0d-2616-45d7-979f-0b9f43fb468e	grade	2026-02-14 19:54:07.793	nazareth-baptist
cmlmqix4g0015qj01m61mnhml	cmlmqix4c000vqj01g91a2t82	bf74d5e3-8880-4044-bc5d-59c76e795b0a	grade	2026-02-14 19:54:07.793	nazareth-baptist
cmlmqix4g0016qj01tzu8k8zq	cmlmqix4c000vqj01g91a2t82	211f94bf-9aae-4edc-83b8-5f5f63e54ef7	major	2026-02-14 19:54:07.793	nazareth-baptist
cmlmqzjp70004lx01xje6jcop	cmlmqzjp20003lx01dlji44js	84a2cd40-c8a1-4cef-a0f8-2bfdb568d2ea	grade	2026-02-14 20:07:03.548	nazareth-baptist
cmlmqzjp70005lx013n3qfbuv	cmlmqzjp20003lx01dlji44js	bba3b58c-9184-4d7a-a9ff-ac6e08ff38b9	grade	2026-02-14 20:07:03.548	nazareth-baptist
cmlmqzjp70006lx01v73re7ge	cmlmqzjp20003lx01dlji44js	5d777c2f-79dd-4675-af7a-62f6c7049fe1	grade	2026-02-14 20:07:03.548	nazareth-baptist
cmlmqzjp70007lx01u32qa1s4	cmlmqzjp20003lx01dlji44js	878c91ad-7133-4ed4-8579-384a44490f76	grade	2026-02-14 20:07:03.548	nazareth-baptist
cmlmqzjp70008lx01xb4rrxd0	cmlmqzjp20003lx01dlji44js	d99bd5ee-8e30-406a-99d1-97f6eb23d5e6	grade	2026-02-14 20:07:03.548	nazareth-baptist
cmlmqzjp70009lx01nzjekp95	cmlmqzjp20003lx01dlji44js	ab43c67a-611e-42b6-b493-40defb03f823	grade	2026-02-14 20:07:03.548	nazareth-baptist
cmlmqzjp7000alx01chge1mvu	cmlmqzjp20003lx01dlji44js	79c96f2b-1b2b-4862-b069-782f84533050	grade	2026-02-14 20:07:03.548	nazareth-baptist
cmlmqzjp7000blx01huz1iddp	cmlmqzjp20003lx01dlji44js	2f445af3-684e-4bda-b5bf-8777d694bff7	grade	2026-02-14 20:07:03.548	nazareth-baptist
cmlmqzjp7000clx013ljxjbjw	cmlmqzjp20003lx01dlji44js	5b074a0d-2616-45d7-979f-0b9f43fb468e	grade	2026-02-14 20:07:03.548	nazareth-baptist
cmlmqzjp7000dlx01ckkkcv2b	cmlmqzjp20003lx01dlji44js	bf74d5e3-8880-4044-bc5d-59c76e795b0a	grade	2026-02-14 20:07:03.548	nazareth-baptist
cmlmqzjp7000elx01wfyczm8s	cmlmqzjp20003lx01dlji44js	211f94bf-9aae-4edc-83b8-5f5f63e54ef7	major	2026-02-14 20:07:03.548	nazareth-baptist
cmlmr8hth0002oo01wege72ps	cmlmr8hte0001oo01xhbsm3r6	84a2cd40-c8a1-4cef-a0f8-2bfdb568d2ea	grade	2026-02-14 20:14:01.014	nazareth-baptist
cmlmr8hth0003oo01qgrax23s	cmlmr8hte0001oo01xhbsm3r6	bba3b58c-9184-4d7a-a9ff-ac6e08ff38b9	grade	2026-02-14 20:14:01.014	nazareth-baptist
cmlmr8hth0004oo01msssktqg	cmlmr8hte0001oo01xhbsm3r6	5d777c2f-79dd-4675-af7a-62f6c7049fe1	grade	2026-02-14 20:14:01.014	nazareth-baptist
cmlmr8hth0005oo015f76b441	cmlmr8hte0001oo01xhbsm3r6	878c91ad-7133-4ed4-8579-384a44490f76	grade	2026-02-14 20:14:01.014	nazareth-baptist
cmlmr8hth0006oo0183ho7zdz	cmlmr8hte0001oo01xhbsm3r6	d99bd5ee-8e30-406a-99d1-97f6eb23d5e6	grade	2026-02-14 20:14:01.014	nazareth-baptist
cmlmr8hth0007oo01surywcqo	cmlmr8hte0001oo01xhbsm3r6	ab43c67a-611e-42b6-b493-40defb03f823	grade	2026-02-14 20:14:01.014	nazareth-baptist
cmlmr8hth0008oo01c5didc6h	cmlmr8hte0001oo01xhbsm3r6	79c96f2b-1b2b-4862-b069-782f84533050	grade	2026-02-14 20:14:01.014	nazareth-baptist
cmlmr8hth0009oo01wcs2j0j1	cmlmr8hte0001oo01xhbsm3r6	2f445af3-684e-4bda-b5bf-8777d694bff7	grade	2026-02-14 20:14:01.014	nazareth-baptist
cmlmr8hth000aoo01ezsphxzx	cmlmr8hte0001oo01xhbsm3r6	5b074a0d-2616-45d7-979f-0b9f43fb468e	grade	2026-02-14 20:14:01.014	nazareth-baptist
cmlmr8u9k0014oo01k090c583	cmlmr8u9f0013oo01dnu9fp3d	84a2cd40-c8a1-4cef-a0f8-2bfdb568d2ea	grade	2026-02-14 20:14:17.144	nazareth-baptist
cmlmr8u9k0015oo01yszgkyb3	cmlmr8u9f0013oo01dnu9fp3d	bba3b58c-9184-4d7a-a9ff-ac6e08ff38b9	grade	2026-02-14 20:14:17.144	nazareth-baptist
cmlmr8u9k0016oo014051y0a2	cmlmr8u9f0013oo01dnu9fp3d	5d777c2f-79dd-4675-af7a-62f6c7049fe1	grade	2026-02-14 20:14:17.144	nazareth-baptist
cmlmr8u9k0017oo010wre3kt9	cmlmr8u9f0013oo01dnu9fp3d	878c91ad-7133-4ed4-8579-384a44490f76	grade	2026-02-14 20:14:17.144	nazareth-baptist
cmlmr8u9k0018oo01l4vhqq6t	cmlmr8u9f0013oo01dnu9fp3d	d99bd5ee-8e30-406a-99d1-97f6eb23d5e6	grade	2026-02-14 20:14:17.144	nazareth-baptist
cmlmr8u9k0019oo01d71bornj	cmlmr8u9f0013oo01dnu9fp3d	ab43c67a-611e-42b6-b493-40defb03f823	grade	2026-02-14 20:14:17.144	nazareth-baptist
cmlmr8u9k001aoo015pws0ysz	cmlmr8u9f0013oo01dnu9fp3d	79c96f2b-1b2b-4862-b069-782f84533050	grade	2026-02-14 20:14:17.144	nazareth-baptist
cmlmr8u9k001boo01jxe92nlr	cmlmr8u9f0013oo01dnu9fp3d	2f445af3-684e-4bda-b5bf-8777d694bff7	grade	2026-02-14 20:14:17.144	nazareth-baptist
cmlmr8u9k001coo017suyh1xv	cmlmr8u9f0013oo01dnu9fp3d	5b074a0d-2616-45d7-979f-0b9f43fb468e	grade	2026-02-14 20:14:17.144	nazareth-baptist
cmlmr8u9k001doo01i1faxba8	cmlmr8u9f0013oo01dnu9fp3d	bf74d5e3-8880-4044-bc5d-59c76e795b0a	grade	2026-02-14 20:14:17.144	nazareth-baptist
cmlmr8u9k001eoo01mpj46clb	cmlmr8u9f0013oo01dnu9fp3d	211f94bf-9aae-4edc-83b8-5f5f63e54ef7	major	2026-02-14 20:14:17.144	nazareth-baptist
cmlms1ao60004jv01mm1fv62o	cmlms1ao20003jv01zyhz4ej1	84a2cd40-c8a1-4cef-a0f8-2bfdb568d2ea	grade	2026-02-14 20:36:24.775	nazareth-baptist
cmlms1ao60005jv01i0ukyutb	cmlms1ao20003jv01zyhz4ej1	bba3b58c-9184-4d7a-a9ff-ac6e08ff38b9	grade	2026-02-14 20:36:24.775	nazareth-baptist
cmlms1ao60006jv01hbqblagr	cmlms1ao20003jv01zyhz4ej1	5d777c2f-79dd-4675-af7a-62f6c7049fe1	grade	2026-02-14 20:36:24.775	nazareth-baptist
cmlms1ao60007jv01uizm6kpv	cmlms1ao20003jv01zyhz4ej1	878c91ad-7133-4ed4-8579-384a44490f76	grade	2026-02-14 20:36:24.775	nazareth-baptist
cmlms1ao60008jv01h8ks0c9v	cmlms1ao20003jv01zyhz4ej1	d99bd5ee-8e30-406a-99d1-97f6eb23d5e6	grade	2026-02-14 20:36:24.775	nazareth-baptist
cmlms1ao60009jv01bjrivimg	cmlms1ao20003jv01zyhz4ej1	ab43c67a-611e-42b6-b493-40defb03f823	grade	2026-02-14 20:36:24.775	nazareth-baptist
cmlms1ao6000ajv01kfdttwcs	cmlms1ao20003jv01zyhz4ej1	79c96f2b-1b2b-4862-b069-782f84533050	grade	2026-02-14 20:36:24.775	nazareth-baptist
cmlms1ao6000bjv01pmry17cw	cmlms1ao20003jv01zyhz4ej1	2f445af3-684e-4bda-b5bf-8777d694bff7	grade	2026-02-14 20:36:24.775	nazareth-baptist
cmlms1ao6000cjv017938jwew	cmlms1ao20003jv01zyhz4ej1	5b074a0d-2616-45d7-979f-0b9f43fb468e	grade	2026-02-14 20:36:24.775	nazareth-baptist
cmlms1ao6000djv01rnj1xgj2	cmlms1ao20003jv01zyhz4ej1	bf74d5e3-8880-4044-bc5d-59c76e795b0a	grade	2026-02-14 20:36:24.775	nazareth-baptist
cmlms1ao6000ejv015f0xj7i9	cmlms1ao20003jv01zyhz4ej1	211f94bf-9aae-4edc-83b8-5f5f63e54ef7	major	2026-02-14 20:36:24.775	nazareth-baptist
cmlms1ao6000fjv01o8tbamvc	cmlms1ao20003jv01zyhz4ej1	312fbc07-060f-4b54-a5b2-26cce9d83e65	major_technological	2026-02-14 20:36:24.775	nazareth-baptist
\.


--
-- Data for Name: Subject; Type: TABLE DATA; Schema: public; Owner: classmate
--

COPY public."Subject" (id, name, "schoolId") FROM stdin;
sub_hebrew	Hebrew	demo-school
sub_pe	PE	demo-school
sub_religion	Religion	demo-school
sub_chapel	Chapel	demo-school
sub_chemistry	Chemistry	demo-school
sub_biology	Biology	demo-school
sub_electronics	Electronics	demo-school
sub_physics	Physics	demo-school
sub_computer_science	Computer Science	demo-school
sub_math	Math	demo-school
sub_arabic	Arabic	demo-school
sub_english	English	demo-school
13e66761-da74-4866-88e5-7d2fa588dc87	Education	demo-school
052a07e9-7224-4531-b063-f841e349036c	History	demo-school
bd44d7be-b5d3-4230-8346-eab39774957c	Geography	demo-school
4e94e5a1-9df3-45b9-9d31-2c6321aeeb23	CS	demo-school
d75a8037-7868-4178-84f5-f4e6bda4e294	Research	demo-school
d3db3f9d-2269-4d5e-9ac5-5461d27d4531	Driving Theory	demo-school
e46f7830-d205-438d-ad36-67364bdf7b7e	Science	demo-school
d99bd5ee-8e30-406a-99d1-97f6eb23d5e6	Math	nazareth-baptist
79c96f2b-1b2b-4862-b069-782f84533050	English	nazareth-baptist
ab43c67a-611e-42b6-b493-40defb03f823	Arabic	nazareth-baptist
84a2cd40-c8a1-4cef-a0f8-2bfdb568d2ea	Hebrew	nazareth-baptist
5d777c2f-79dd-4675-af7a-62f6c7049fe1	Religion	nazareth-baptist
878c91ad-7133-4ed4-8579-384a44490f76	Chapel	nazareth-baptist
bba3b58c-9184-4d7a-a9ff-ac6e08ff38b9	PE	nazareth-baptist
2f445af3-684e-4bda-b5bf-8777d694bff7	Education	nazareth-baptist
5b074a0d-2616-45d7-979f-0b9f43fb468e	History	nazareth-baptist
61ff0c29-6e70-4328-8045-ea8cc2ec36a1	Geography	nazareth-baptist
6957fe92-bafa-4ce7-88b2-3ef92df237e5	Biology	nazareth-baptist
d50c900c-617c-4e0a-a384-f936a47c9846	Chemistry	nazareth-baptist
aefc8b09-6ed6-4143-8743-fed95a91a89c	Physics	nazareth-baptist
211f94bf-9aae-4edc-83b8-5f5f63e54ef7	Electronics	nazareth-baptist
8a2fd8a6-cb1b-4af4-83db-a27ab2e9cf54	CS	nazareth-baptist
312fbc07-060f-4b54-a5b2-26cce9d83e65	Research	nazareth-baptist
bf74d5e3-8880-4044-bc5d-59c76e795b0a	Driving Theory	nazareth-baptist
d6929dbf-a85f-4570-a7b8-5d378018afb3	Science	nazareth-baptist
\.


--
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: classmate
--

COPY public."User" (id, email, "passwordHash", "fullName", username, "nationalId", grade, "schoolId", "createdAt", "scientificMajor", "technologicalMajor", "mathUnits", "englishUnits") FROM stdin;
cmljw8ww0001ppm010w9hwtqa	t1770927059@example.com	$2b$10$m1Xl68ltHdGuIsJ5VIdDwu2GTfJ0xFc1/YNRe1JgT1DlxrVQ.1dKG	Tony Test	tony_1770927059	\N	7	demo-school	2026-02-13 10:20:05.432	\N	\N	\N	\N
cmlkxg3iv0001lg01lp26xafp	abto@gmail.xom	$2b$10$04dxta7WfSVbSh9RUmNMeOjkG6jS8u.t1R5hnyYW4H.mmtTZ4btem	tony	tony11	\N	10	demo-school	2026-02-13 13:32:21.079	\N	\N	\N	\N
cmllcj0530001ma019pqywijm	ttttt@ttttt.com	$2b$10$BUD9utUXzxRC2xQTdzYbz.mVk3IlkLBRIHz8PQWujzchyq2MhMoXK	tt	ttttt	\N	10	demo-school	2026-02-13 20:34:30.896	\N	\N	\N	\N
cmlld20ze0001sc0183k3uvtd	tony_reg_test_1771015758@example.com	$2b$10$RFQHXpX8wVbOrCyDOkpnp.eYZtelgge1TS71VpaxWtRKZfxfW2wLm	Tony Reg Test	tony_reg_1771015758	\N	10	demo-school	2026-02-13 20:49:18.458	Physics	\N	5	5
cmlld849z0001ny01nt0z34dd	hoseph22@gmail.com	$2b$10$zWixour40PhwHkW8elcJbOgX/4Dk8hhfq3luIjrtdGDWeLs22ZKmC	joseph	hoseph2	\N	10	demo-school	2026-02-13 20:54:02.663	\N	\N	\N	\N
cmlldtgsb000lny011fa2m00w	joseph22@gmail.com	$2b$10$t39Stkan5Aubh5kuOfCUT.Kj.Vaw6oy72yIFe8Bt0AdBqsvRuk5LG	joseph	joseph1	\N	10	demo-school	2026-02-13 21:10:38.651	\N	\N	\N	\N
cmlmfts1g0001pf01gdjhr7u3	tony@gmail.com	$2b$10$7eTeijjvrburH580Q8gLz.IOJG.Ba27ePfEvDGWitRgKa9u33mV6S	12344	1234	\N	10	demo-school	2026-02-14 14:54:38.644	\N	\N	\N	\N
cmlmfzbn7000lpf01zzglwtgg	student_1771081137@example.com	$2b$10$ai8bxxVJHpuzlnBLpfAq9./s4gdl2fYacMaez1P0kqXPh.DZC7HLy	Test Student	student_1771081137	\N	7	demo-school	2026-02-14 14:58:57.331	\N	\N	\N	\N
cmlmgqd4l001npf010agnz6ck	tony1@gmail.com	$2b$10$.oo7BhFugm.vWYvdxqKPye4wsyabSz.NgqWuWhRzQ2gchtJXZAHIa	123456	2134567	\N	10	demo-school	2026-02-14 15:19:58.966	\N	\N	\N	\N
cmlmhk3hg0027pf01cwt0fupx	student_1771083786@example.com	$2b$10$kLlYcBCgG5yvL1QBCStzM.zxaeRpc0a873tgOZ8RpbMEF8xgZ0jpe	Test Student	student_1771083786	\N	7	demo-school	2026-02-14 15:43:06.142	\N	\N	\N	\N
cmlmhpjtw002rpf01dswhe3mn	g10_nomaj_1771084040@example.com	$2b$10$a.jBoFbHxLdBgy8N1bm.4ufkT9e6LkjMPCTmb97Ltz0MS6pyFvu3m	G10 No Major	g10_nomaj_1771084040	\N	10	demo-school	2026-02-14 15:47:20.612	\N	\N	\N	\N
cmlmi3ful0037pf01mlb614dc	g10_test_1771084688@example.com	$2b$10$IJ5u5X93n9fdG3lZ0JEflePn0M1weCFBkBQ12o6P4XDAiSLNkAhFy	G10 Test	g10_test_1771084688	\N	10	demo-school	2026-02-14 15:58:08.637	\N	\N	5	5
cmlmi8ige003npf01bbc9gwgy	sjxbsudh@gmail.com	$2b$10$7VLSXsK/WCMGMJFK2nTXWu8LMCt1zpe43jyaOTeBHkGgMAGeIE6fa	jsodneux	syhzhsuxxb	\N	10	demo-school	2026-02-14 16:02:05.294	Physics	\N	5	5
cmlmi956o0045pf01quuhuv2g	anzjwpaks@suzus.com	$2b$10$l.Axskm/ifTzJk4IA28Yoe0geMuesI26oi2ab9bMAjcl3bKpu93C2	wjxusnxpwlz	akapziwjznz	\N	10	demo-school	2026-02-14 16:02:34.752	Chemistry	Electronics	5	5
cmlmkxue20001mu01yzwch73w	g10_elec_1771089466@example.com	$2b$10$Yqm91c54JODLPjUVCMAhi.AnJEXKDkokOMfCaU0g4dmI0viaP.l4C	G10 Electronics	g10_elec_1771089466	\N	10	demo-school	2026-02-14 17:17:46.394	\N	Electronics	5	5
cmlmkz7je0003mu010k7e6wog	g10_phy_1771089530@example.com	$2b$10$AMXmrQJafJ2H7unlfB2AceYQcmONCTUmq925VIZjWSO2sK/IZBS7a	G10 Physics	g10_phy_1771089530	\N	10	demo-school	2026-02-14 17:18:50.09	Physics	\N	5	5
cmlml3bwt0005mu0112gzs0ms	hszuehzus@gsuzbsu.xom	$2b$10$MXdOuP2Egs9guUDqqPWHKOH0Xu1OKUpv4RFceFyM0h8CVZIxgnh/O	طهيهطيرطتي	صايايعظايتظسر	\N	10	demo-school	2026-02-14 17:22:02.381	Environment	Communication	5	5
cmlml4bhz000dmu010u5rtd02	hszuehzus@gmail.com	$2b$10$SCs3Sks7h60OZa8o5WH7VuREfgQAkE8iW4w0QfH87lOubPAlBVV0q	shxushx	whdush	\N	10	demo-school	2026-02-14 17:22:48.496	Environment	Communication	5	5
cmlml88t4000jmu01q1v3vc2r	dbg_1771089951@example.com	$2b$10$aXzFjZCSyc7kvQrwPbjzmegJfDzfxqIk9ABa90yJSmXdwT/km/Hw6	Debug User	dbg_1771089951	\N	10	demo-school	2026-02-14 17:25:51.64	\N	Electronics	5	5
cmlmlbsgj000lmu01ohe7fimt	g10_elec_1771090116@example.com	$2b$10$83rPPGEtG/.cTxFZottlHOd/QCC5Vj.dBbdUaq2r2k/r6atrDHvDu	G10 Electronics	g10_elec_1771090116	\N	10	demo-school	2026-02-14 17:28:37.068	\N	Electronics	5	5
cmlmldu5r000nmu01vv58483l	samer@gmail.com	$2b$10$ZQkwNtkBBms6VRKxSSLyzuKNqLlsQRaEyMEUzeBZRPFt.iLqpFt4e	samer	samer01	\N	10	demo-school	2026-02-14 17:30:12.592	Physics	Computer Science	5	5
cmlmm71kj0001li0149ow96ih	g10_elec_1771091575@example.com	$2b$10$DkgGKYtgxPcSp4SDgmxCvOpRK319Lyt8SFV6Hm5WH/e3wvfc6YuGa	G10 Electronics	g10_elec_1771091575	\N	10	demo-school	2026-02-14 17:52:55.22	\N	Electronics	5	5
cmlmq65gt0001qj01cygw4mly	g10_elec_1771098251@example.com	$2b$10$gBlIWV7IsQmb9aMLP71BPeCUMy4OtqbuUNAR2qGjNIGzJIWvnF/zK	G10 Electronics	g10_elec_1771098251	\N	10	demo-school	2026-02-14 19:44:12.078	\N	Electronics	5	5
cmlmqix4c000vqj01g91a2t82	nbs_g10_elec_1771098847@example.com	$2b$10$tGtpSJtjSRBz4U/CtSaeCO8rtXV8dsC9ijchsg5PjfiuwphHkDiy.	NBS G10 Electronics	nbs_g10_elec_1771098847	\N	10	nazareth-baptist	2026-02-14 19:54:07.78	\N	Electronics	5	5
cmlmqzebm0001lx015toypt8d	nbs_badmajor_1771099616@example.com	$2b$10$7B7NWiVMg7eIwzriFCQwweq8AZnMPW2CiBLOQtwoCkLTTxgIBIUKS	NBS BadMajor	nbs_badmajor_1771099616	\N	10	nazareth-baptist	2026-02-14 20:06:56.578	\N	HackerMajor9000	5	5
cmlmqzjp20003lx01dlji44js	nbs_g10_elec_1771099623@example.com	$2b$10$XkupEA2gddfXHK0irhM8d.Y25UmrKb0SWJSxg94i5y3xySxS6/o3W	NBS G10 Electronics	nbs_g10_elec_1771099623	\N	10	nazareth-baptist	2026-02-14 20:07:03.542	\N	Electronics	5	5
cmlmr8u9f0013oo01dnu9fp3d	nbs_g10_elec2_1771100057@example.com	$2b$10$VBb8qD2NgZj2adrTh9dGPOCe9SsPNV.dqyCdEvq8cX93b8uJklqZe	NBS G10 Electronics 2	nbs_g10_elec2_1771100057	\N	10	nazareth-baptist	2026-02-14 20:14:17.139	\N	Electronics	5	5
cmlmr8hte0001oo01xhbsm3r6	admin_nbs_1771100040@example.com	$2b$10$pRuN4WPt/8vNaLVUZchjwOETX50Q1/Wnq6GDoi7Jhi6lCJ9m74Iu.	NBS Admin	admin_nbs_1771100040	\N	12	nazareth-baptist	2026-02-14 20:14:01.01	\N	\N	\N	\N
cmlms1ao20003jv01zyhz4ej1	nbs_g10_elec3_1771101384@example.com	$2b$10$nQSvYVuguN9e0RzVIX6vM.M2kwc55G9kQv/ghkt2XwJNpb7xhitE6	NBS G10 Electronics 3	nbs_g10_elec3_1771101384	\N	10	nazareth-baptist	2026-02-14 20:36:24.763	\N	Electronics	5	5
\.


--
-- Data for Name: UserRole; Type: TABLE DATA; Schema: public; Owner: classmate
--

COPY public."UserRole" ("userId", "roleId") FROM stdin;
cmljw8ww0001ppm010w9hwtqa	role_admin
cmlmr8hte0001oo01xhbsm3r6	role_admin
\.


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: classmate
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
02925bbf-7170-48ca-aebb-7f1de3699ecb	bf25e498b504858a9a1243ed83e0567627422acc64c99ee28e44239d1c2fbb9c	2026-02-13 10:19:58.507567+00	20260212150748_init	\N	\N	2026-02-13 10:19:58.476872+00	1
a74ce852-4704-4679-86e7-a7689f5f98f0	3b44ff1b4325e041cbade425c937724c0353e0339e456ccabcab3bbbe9deabbf	2026-02-13 10:20:00.011622+00	20260213102000_init_clean	\N	\N	2026-02-13 10:20:00.00334+00	1
\.


--
-- Name: AssignmentSubmission AssignmentSubmission_pkey; Type: CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."AssignmentSubmission"
    ADD CONSTRAINT "AssignmentSubmission_pkey" PRIMARY KEY (id);


--
-- Name: Assignment Assignment_pkey; Type: CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."Assignment"
    ADD CONSTRAINT "Assignment_pkey" PRIMARY KEY (id);


--
-- Name: AttendanceRecord AttendanceRecord_pkey; Type: CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."AttendanceRecord"
    ADD CONSTRAINT "AttendanceRecord_pkey" PRIMARY KEY (id);


--
-- Name: ClassroomMember ClassroomMember_pkey; Type: CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."ClassroomMember"
    ADD CONSTRAINT "ClassroomMember_pkey" PRIMARY KEY (id);


--
-- Name: Classroom Classroom_pkey; Type: CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."Classroom"
    ADD CONSTRAINT "Classroom_pkey" PRIMARY KEY (id);


--
-- Name: GradeSubjectPack GradeSubjectPack_pkey; Type: CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."GradeSubjectPack"
    ADD CONSTRAINT "GradeSubjectPack_pkey" PRIMARY KEY (id);


--
-- Name: Grade Grade_pkey; Type: CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."Grade"
    ADD CONSTRAINT "Grade_pkey" PRIMARY KEY (id);


--
-- Name: MajorSubject MajorSubject_pkey; Type: CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."MajorSubject"
    ADD CONSTRAINT "MajorSubject_pkey" PRIMARY KEY (id);


--
-- Name: Major Major_pkey; Type: CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."Major"
    ADD CONSTRAINT "Major_pkey" PRIMARY KEY (id);


--
-- Name: Message Message_pkey; Type: CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."Message"
    ADD CONSTRAINT "Message_pkey" PRIMARY KEY (id);


--
-- Name: Notification Notification_pkey; Type: CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."Notification"
    ADD CONSTRAINT "Notification_pkey" PRIMARY KEY (id);


--
-- Name: Role Role_pkey; Type: CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."Role"
    ADD CONSTRAINT "Role_pkey" PRIMARY KEY (id);


--
-- Name: ScheduleEntry ScheduleEntry_pkey; Type: CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."ScheduleEntry"
    ADD CONSTRAINT "ScheduleEntry_pkey" PRIMARY KEY (id);


--
-- Name: School School_pkey; Type: CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."School"
    ADD CONSTRAINT "School_pkey" PRIMARY KEY (id);


--
-- Name: SolutionComment SolutionComment_pkey; Type: CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."SolutionComment"
    ADD CONSTRAINT "SolutionComment_pkey" PRIMARY KEY (id);


--
-- Name: SolutionLike SolutionLike_pkey; Type: CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."SolutionLike"
    ADD CONSTRAINT "SolutionLike_pkey" PRIMARY KEY (id);


--
-- Name: Solution Solution_pkey; Type: CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."Solution"
    ADD CONSTRAINT "Solution_pkey" PRIMARY KEY (id);


--
-- Name: StudentSubject StudentSubject_pkey; Type: CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."StudentSubject"
    ADD CONSTRAINT "StudentSubject_pkey" PRIMARY KEY (id);


--
-- Name: Subject Subject_pkey; Type: CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."Subject"
    ADD CONSTRAINT "Subject_pkey" PRIMARY KEY (id);


--
-- Name: UserRole UserRole_pkey; Type: CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."UserRole"
    ADD CONSTRAINT "UserRole_pkey" PRIMARY KEY ("userId", "roleId");


--
-- Name: User User_pkey; Type: CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_pkey" PRIMARY KEY (id);


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: AssignmentSubmission_assignmentId_idx; Type: INDEX; Schema: public; Owner: classmate
--

CREATE INDEX "AssignmentSubmission_assignmentId_idx" ON public."AssignmentSubmission" USING btree ("assignmentId");


--
-- Name: AssignmentSubmission_assignmentId_userId_key; Type: INDEX; Schema: public; Owner: classmate
--

CREATE UNIQUE INDEX "AssignmentSubmission_assignmentId_userId_key" ON public."AssignmentSubmission" USING btree ("assignmentId", "userId");


--
-- Name: AssignmentSubmission_userId_idx; Type: INDEX; Schema: public; Owner: classmate
--

CREATE INDEX "AssignmentSubmission_userId_idx" ON public."AssignmentSubmission" USING btree ("userId");


--
-- Name: Assignment_schoolId_classroomId_idx; Type: INDEX; Schema: public; Owner: classmate
--

CREATE INDEX "Assignment_schoolId_classroomId_idx" ON public."Assignment" USING btree ("schoolId", "classroomId");


--
-- Name: Assignment_subjectId_idx; Type: INDEX; Schema: public; Owner: classmate
--

CREATE INDEX "Assignment_subjectId_idx" ON public."Assignment" USING btree ("subjectId");


--
-- Name: AttendanceRecord_userId_date_idx; Type: INDEX; Schema: public; Owner: classmate
--

CREATE INDEX "AttendanceRecord_userId_date_idx" ON public."AttendanceRecord" USING btree ("userId", date);


--
-- Name: ClassroomMember_classroomId_userId_key; Type: INDEX; Schema: public; Owner: classmate
--

CREATE UNIQUE INDEX "ClassroomMember_classroomId_userId_key" ON public."ClassroomMember" USING btree ("classroomId", "userId");


--
-- Name: ClassroomMember_userId_idx; Type: INDEX; Schema: public; Owner: classmate
--

CREATE INDEX "ClassroomMember_userId_idx" ON public."ClassroomMember" USING btree ("userId");


--
-- Name: Classroom_schoolId_grade_idx; Type: INDEX; Schema: public; Owner: classmate
--

CREATE INDEX "Classroom_schoolId_grade_idx" ON public."Classroom" USING btree ("schoolId", grade);


--
-- Name: Classroom_schoolId_grade_subjectId_key; Type: INDEX; Schema: public; Owner: classmate
--

CREATE UNIQUE INDEX "Classroom_schoolId_grade_subjectId_key" ON public."Classroom" USING btree ("schoolId", grade, "subjectId");


--
-- Name: MajorSubject_schoolId_majorId_idx; Type: INDEX; Schema: public; Owner: classmate
--

CREATE INDEX "MajorSubject_schoolId_majorId_idx" ON public."MajorSubject" USING btree ("schoolId", "majorId");


--
-- Name: MajorSubject_schoolId_majorId_subjectId_key; Type: INDEX; Schema: public; Owner: classmate
--

CREATE UNIQUE INDEX "MajorSubject_schoolId_majorId_subjectId_key" ON public."MajorSubject" USING btree ("schoolId", "majorId", "subjectId");


--
-- Name: Major_schoolId_type_idx; Type: INDEX; Schema: public; Owner: classmate
--

CREATE INDEX "Major_schoolId_type_idx" ON public."Major" USING btree ("schoolId", type);


--
-- Name: Major_schoolId_type_name_key; Type: INDEX; Schema: public; Owner: classmate
--

CREATE UNIQUE INDEX "Major_schoolId_type_name_key" ON public."Major" USING btree ("schoolId", type, name);


--
-- Name: Role_name_key; Type: INDEX; Schema: public; Owner: classmate
--

CREATE UNIQUE INDEX "Role_name_key" ON public."Role" USING btree (name);


--
-- Name: ScheduleEntry_classroomId_startAt_idx; Type: INDEX; Schema: public; Owner: classmate
--

CREATE INDEX "ScheduleEntry_classroomId_startAt_idx" ON public."ScheduleEntry" USING btree ("classroomId", "startAt");


--
-- Name: ScheduleEntry_schoolId_startAt_idx; Type: INDEX; Schema: public; Owner: classmate
--

CREATE INDEX "ScheduleEntry_schoolId_startAt_idx" ON public."ScheduleEntry" USING btree ("schoolId", "startAt");


--
-- Name: ScheduleEntry_userId_startAt_idx; Type: INDEX; Schema: public; Owner: classmate
--

CREATE INDEX "ScheduleEntry_userId_startAt_idx" ON public."ScheduleEntry" USING btree ("userId", "startAt");


--
-- Name: School_name_key; Type: INDEX; Schema: public; Owner: classmate
--

CREATE UNIQUE INDEX "School_name_key" ON public."School" USING btree (name);


--
-- Name: SolutionLike_solutionId_userId_key; Type: INDEX; Schema: public; Owner: classmate
--

CREATE UNIQUE INDEX "SolutionLike_solutionId_userId_key" ON public."SolutionLike" USING btree ("solutionId", "userId");


--
-- Name: Solution_schoolId_classroomId_idx; Type: INDEX; Schema: public; Owner: classmate
--

CREATE INDEX "Solution_schoolId_classroomId_idx" ON public."Solution" USING btree ("schoolId", "classroomId");


--
-- Name: Solution_subjectId_grade_book_page_idx; Type: INDEX; Schema: public; Owner: classmate
--

CREATE INDEX "Solution_subjectId_grade_book_page_idx" ON public."Solution" USING btree ("subjectId", grade, book, page);


--
-- Name: Subject_schoolId_idx; Type: INDEX; Schema: public; Owner: classmate
--

CREATE INDEX "Subject_schoolId_idx" ON public."Subject" USING btree ("schoolId");


--
-- Name: Subject_schoolId_name_key; Type: INDEX; Schema: public; Owner: classmate
--

CREATE UNIQUE INDEX "Subject_schoolId_name_key" ON public."Subject" USING btree ("schoolId", name);


--
-- Name: UserRole_roleId_idx; Type: INDEX; Schema: public; Owner: classmate
--

CREATE INDEX "UserRole_roleId_idx" ON public."UserRole" USING btree ("roleId");


--
-- Name: User_email_key; Type: INDEX; Schema: public; Owner: classmate
--

CREATE UNIQUE INDEX "User_email_key" ON public."User" USING btree (email);


--
-- Name: User_nationalId_key; Type: INDEX; Schema: public; Owner: classmate
--

CREATE UNIQUE INDEX "User_nationalId_key" ON public."User" USING btree ("nationalId");


--
-- Name: User_username_key; Type: INDEX; Schema: public; Owner: classmate
--

CREATE UNIQUE INDEX "User_username_key" ON public."User" USING btree (username);


--
-- Name: AssignmentSubmission AssignmentSubmission_assignmentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."AssignmentSubmission"
    ADD CONSTRAINT "AssignmentSubmission_assignmentId_fkey" FOREIGN KEY ("assignmentId") REFERENCES public."Assignment"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: AssignmentSubmission AssignmentSubmission_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."AssignmentSubmission"
    ADD CONSTRAINT "AssignmentSubmission_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Assignment Assignment_classroomId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."Assignment"
    ADD CONSTRAINT "Assignment_classroomId_fkey" FOREIGN KEY ("classroomId") REFERENCES public."Classroom"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Assignment Assignment_createdById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."Assignment"
    ADD CONSTRAINT "Assignment_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Assignment Assignment_subjectId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."Assignment"
    ADD CONSTRAINT "Assignment_subjectId_fkey" FOREIGN KEY ("subjectId") REFERENCES public."Subject"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: AttendanceRecord AttendanceRecord_subjectId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."AttendanceRecord"
    ADD CONSTRAINT "AttendanceRecord_subjectId_fkey" FOREIGN KEY ("subjectId") REFERENCES public."Subject"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: AttendanceRecord AttendanceRecord_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."AttendanceRecord"
    ADD CONSTRAINT "AttendanceRecord_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ClassroomMember ClassroomMember_classroomId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."ClassroomMember"
    ADD CONSTRAINT "ClassroomMember_classroomId_fkey" FOREIGN KEY ("classroomId") REFERENCES public."Classroom"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ClassroomMember ClassroomMember_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."ClassroomMember"
    ADD CONSTRAINT "ClassroomMember_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Classroom Classroom_subjectId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."Classroom"
    ADD CONSTRAINT "Classroom_subjectId_fkey" FOREIGN KEY ("subjectId") REFERENCES public."Subject"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: GradeSubjectPack GradeSubjectPack_subjectId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."GradeSubjectPack"
    ADD CONSTRAINT "GradeSubjectPack_subjectId_fkey" FOREIGN KEY ("subjectId") REFERENCES public."Subject"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Grade Grade_subjectId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."Grade"
    ADD CONSTRAINT "Grade_subjectId_fkey" FOREIGN KEY ("subjectId") REFERENCES public."Subject"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Grade Grade_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."Grade"
    ADD CONSTRAINT "Grade_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: MajorSubject MajorSubject_majorId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."MajorSubject"
    ADD CONSTRAINT "MajorSubject_majorId_fkey" FOREIGN KEY ("majorId") REFERENCES public."Major"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: MajorSubject MajorSubject_subjectId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."MajorSubject"
    ADD CONSTRAINT "MajorSubject_subjectId_fkey" FOREIGN KEY ("subjectId") REFERENCES public."Subject"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Message Message_classroomId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."Message"
    ADD CONSTRAINT "Message_classroomId_fkey" FOREIGN KEY ("classroomId") REFERENCES public."Classroom"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Message Message_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."Message"
    ADD CONSTRAINT "Message_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Notification Notification_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."Notification"
    ADD CONSTRAINT "Notification_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ScheduleEntry ScheduleEntry_classroomId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."ScheduleEntry"
    ADD CONSTRAINT "ScheduleEntry_classroomId_fkey" FOREIGN KEY ("classroomId") REFERENCES public."Classroom"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ScheduleEntry ScheduleEntry_subjectId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."ScheduleEntry"
    ADD CONSTRAINT "ScheduleEntry_subjectId_fkey" FOREIGN KEY ("subjectId") REFERENCES public."Subject"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ScheduleEntry ScheduleEntry_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."ScheduleEntry"
    ADD CONSTRAINT "ScheduleEntry_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: SolutionComment SolutionComment_solutionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."SolutionComment"
    ADD CONSTRAINT "SolutionComment_solutionId_fkey" FOREIGN KEY ("solutionId") REFERENCES public."Solution"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SolutionComment SolutionComment_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."SolutionComment"
    ADD CONSTRAINT "SolutionComment_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SolutionLike SolutionLike_solutionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."SolutionLike"
    ADD CONSTRAINT "SolutionLike_solutionId_fkey" FOREIGN KEY ("solutionId") REFERENCES public."Solution"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SolutionLike SolutionLike_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."SolutionLike"
    ADD CONSTRAINT "SolutionLike_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Solution Solution_classroomId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."Solution"
    ADD CONSTRAINT "Solution_classroomId_fkey" FOREIGN KEY ("classroomId") REFERENCES public."Classroom"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Solution Solution_subjectId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."Solution"
    ADD CONSTRAINT "Solution_subjectId_fkey" FOREIGN KEY ("subjectId") REFERENCES public."Subject"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Solution Solution_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."Solution"
    ADD CONSTRAINT "Solution_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: StudentSubject StudentSubject_subjectId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."StudentSubject"
    ADD CONSTRAINT "StudentSubject_subjectId_fkey" FOREIGN KEY ("subjectId") REFERENCES public."Subject"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: StudentSubject StudentSubject_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."StudentSubject"
    ADD CONSTRAINT "StudentSubject_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: UserRole UserRole_roleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."UserRole"
    ADD CONSTRAINT "UserRole_roleId_fkey" FOREIGN KEY ("roleId") REFERENCES public."Role"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: UserRole UserRole_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."UserRole"
    ADD CONSTRAINT "UserRole_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: User User_schoolId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: classmate
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_schoolId_fkey" FOREIGN KEY ("schoolId") REFERENCES public."School"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: classmate
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

\unrestrict CAh3vF4nux6i1a66EQXxJ2MITTwb6HCpRt1tOhANmrt5LDEJKRax8hBAJonF25W

