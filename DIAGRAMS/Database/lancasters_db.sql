CREATE TABLE venue_spaces (
    space_id INT PRIMARY KEY AUTO_INCREMENT,
    space_name VARCHAR(100) NOT NULL,
    space_capacity INT,
    space_type ENUM("Main Hall", "Small Hall", "Meeting Room") NOT NULL
);

CREATE TABLE events (
    event_id INT PRIMARY KEY AUTO_INCREMENT,
    event_name VARCHAR(100) NOT NULL,
    event_type ENUM("Show", "Film", "Meeting") NOT NULL, 
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    space_id INT NOT NULL,
    FOREIGN KEY (space_id) REFERENCES venue_spaces(space_id)
);

CREATE TABLE bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_type VARCHAR(100) NOT NULL,
    booking_status ENUM("Pending", "Confirmed", "Cancelled") DEFAULT "Pending",
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    event_id INT,
    space_id INT,
    client_id INT,
    FOREIGN KEY (event_id) REFERENCES events(event_id),
    FOREIGN KEY (space_id) REFERENCES venue_spaces(space_id),
    FOREIGN KEY (client_id) REFERENCES clients(client_id)
);

CREATE TABLE friends_of_lancaster (
    member_id INT PRIMARY KEY AUTO_INCREMENT,
    member_name VARCHAR(100) NOT NULL,
    contact_email VARCHAR(100) NOT NULL,
    join_date DATE NOT NULL
);

CREATE TABLE film_orders ( 
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    film_name VARCHAR(100) NOT NULL,
    cost DECIMAL(8, 2) NOT NULL,
    screening_date DATE,
    booking_id INT NOT NULL,
    FOREIGN KEY (booking_id) REFERENCES bookings (booking_id)
);

CREATE TABLE promotions (
    promo_id INT PRIMARY KEY AUTO_INCREMENT,
    promo_name VARCHAR(100) NOT NULL,
    promo_type ENUM("Discount", "Event Invite", "Film Promotion") NOT NULL,
    description VARCHAR(255)
);

CREATE TABLE clients ( 
    client_id INT PRIMARY KEY AUTO_INCREMENT,
    client_name VARCHAR(150) NOT NULL,
    contact_name VARCHAR(100) NOT NULL,
    contact_email VARCHAR(100) NOT NULL,
    phone_number INT(11) NOT NULL,
    street_address VARCHAR(150) NOT NULL,
    postcode VARCHAR(10) NOT NULL,
    billing_name VARCHAR(50),
    billing_email VARCHAR(100)
);

CREATE TABLE enquiries (
    enquiry_id INT PRIMARY KEY AUTO_INCREMENT,
    enquiry_type ENUM("Reschedule booking", "Ticket Issues", "Seatings", "Other"),
    enquiry_details VARCHAR(150),
    submitted_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    sent_to ENUM("Operations", "Box OFfice"),
    enquiry_status ENUM("Open", "Closed") DEFAULT "Open",
    client_id INT NOT NULL,
    FOREIGN KEY (client_id) REFERENCES clients(client_id)
);

CREATE TABLE member_promotions (
    promo_id INT NOT NULL,
    member_id INT NOT NULL,
    PRIMARY KEY (promo_id, member_id),
    FOREIGN KEY (promo_id) REFERENCES promotions(promo_id),
    FOREIGN KEY (member_id) REFERENCES friends_of_lancaster(member_id)
);

