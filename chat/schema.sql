--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.6
-- Dumped by pg_dump version 9.5.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: list; Type: TABLE; Schema: public; Owner: yu
--

CREATE TABLE list (
    id integer NOT NULL PRIMARY KEY,
    room text,
    create_timestamp timestamp without time zone
);


ALTER TABLE list OWNER TO yu;

--
-- Name: list_id_seq; Type: SEQUENCE; Schema: public; Owner: yu
--

CREATE SEQUENCE list_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE list_id_seq OWNER TO yu;

--
-- Name: list_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: yu
--

ALTER SEQUENCE list_id_seq OWNED BY list.id;


--
-- Name: msg; Type: TABLE; Schema: public; Owner: yu
--

CREATE TABLE msg (
    id integer NOT NULL PRIMARY KEY,
    room text,
    msg text,
    create_timestamp timestamp without time zone,
    name text
);


ALTER TABLE msg OWNER TO yu;

--
-- Name: msg_id_seq; Type: SEQUENCE; Schema: public; Owner: yu
--

CREATE SEQUENCE msg_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE msg_id_seq OWNER TO yu;

--
-- Name: msg_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: yu
--

ALTER SEQUENCE msg_id_seq OWNED BY msg.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: yu
--

CREATE TABLE users (
    id integer NOT NULL PRIMARY KEY,
    name varchar(16),
    pass varchar(40),
    icon bytea,
    create_timestamp timestamp without time zone
);


ALTER TABLE users OWNER TO yu;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: yu
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE users_id_seq OWNER TO yu;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: yu
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: yu
--

ALTER TABLE ONLY list ALTER COLUMN id SET DEFAULT nextval('list_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: yu
--

ALTER TABLE ONLY msg ALTER COLUMN id SET DEFAULT nextval('msg_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: yu
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

