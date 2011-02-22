CREATE DATABASE mail;

CREATE TABLE acct (
	id INT NOT NULL AUTO_INCREMENT,
	PRIMARY KEY(id),
	addr varchar(256) UNIQUE NOT NULL,
	domain INT NOT NULL,
	password varchar(256) NOT NULL,
	quota INT NOT NULL DEFAULT 10240,
	active BOOL NOT NULL DEFAULT 1
);

CREATE TABLE domain (
	id INT NOT NULL AUTO_INCREMENT,
        PRIMARY KEY(id),
	name varchar(256) UNIQUE NOT NULL,
	max_acct INT NOT NULL DEFAULT 20,
	quota INT NOT NULL DEFAULT 10240,
	active BOOL NOT NULL DEFAULT 1
	
);

CREATE TABLE admuser (
	id INT NOT NULL AUTO_INCREMENT,
        PRIMARY KEY(id),
	username varchar(256) UNIQUE NOT NULL,
	password varchar(256) NOT NULL,
	is_su BOOL NOT NULL DEFAULT 0	
);

CREATE TABLE acl (
	id INT NOT NULL AUTO_INCREMENT,
        PRIMARY KEY(id),
	admuser INT UNIQUE NOT NULL,
	domain INT NOT NULL
);

CREATE TABLE forward (
	id INT NOT NULL AUTO_INCREMENT,
        PRIMARY KEY(id),
	acctid INT NOT NULL,
	addr varchar(256) NOT NULL,
	f_addr varchar(256) NOT NULL
);

GRANT ALL PRIVILEGES ON mail.* TO 'mail'@'localhost' IDENTIFIED BY 'changeme';
INSERT INTO acct (addr, password) VALUES ('cyrus', 'changemetoo');
