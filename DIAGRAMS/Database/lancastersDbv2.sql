-- Clients table (from Client.java)
CREATE TABLE clients (
    client_id INT AUTO_INCREMENT PRIMARY KEY,
    client_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    billing_address TEXT,
    billing_name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_fol_member BOOLEAN DEFAULT FALSE
);

-- Institutions table (for schools/colleges)
CREATE TABLE institutions (
    institution_id INT AUTO_INCREMENT PRIMARY KEY,
    institution_name VARCHAR(100) NOT NULL UNIQUE,
    contact_email VARCHAR(100) NOT NULL UNIQUE,
    contact_phone VARCHAR(20),
    is_accepted BOOLEAN DEFAULT FALSE,
    discount_percentage DECIMAL(5,2) DEFAULT 0.00
);

-- Friends of Lancaster (FOL) members table
CREATE TABLE fol_members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT NOT NULL,
    join_date DATE NOT NULL,
    expiry_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    institution_id INT,
    FOREIGN KEY (client_id) REFERENCES clients(client_id),
    FOREIGN KEY (institution_id) REFERENCES institutions(institution_id)
);

-- Enquiries table (from Enquiry.java)
CREATE TABLE enquiries (
    enquiry_id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT NOT NULL,
    enquiry_type ENUM('SHOW', 'LARGE_BOOKING', 'GROUP_BOOKING', 'RENT_A_ROOM') NOT NULL,
    enquiry_status ENUM('OPEN', 'CLOSED', 'FORWARDED') NOT NULL DEFAULT 'OPEN',
    enquiry_room_type ENUM('SMALL_HALL', 'MEETING_ROOM', 'REHEARSAL_SPACE') NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES clients(client_id)
);

-- Room booking details (from RoomBookingEnquiries.java)
CREATE TABLE enquiry_room_details (
    detail_id INT AUTO_INCREMENT PRIMARY KEY,
    enquiry_id INT NOT NULL,
    layout ENUM('CLASSROOM', 'BOARDROOM', 'PRESENTATION') NULL,
    capacity INT NOT NULL,
    duration ENUM('HOUR', 'HALF_DAY', 'ALL_DAY', 'ALL_WEEK') NOT NULL,
    date VARCHAR(20) NOT NULL,  -- Stored as string per requirements
    time VARCHAR(20) NOT NULL,   -- Stored as string per requirements
    FOREIGN KEY (enquiry_id) REFERENCES enquiries(enquiry_id)
);

CREATE TABLE enquiry_group_booking_details (
    detail_id INT AUTO_INCREMENT PRIMARY KEY,
    enquiry_id INT NOT NULL,
    group_size INT NOT NULL,
    event_name VARCHAR(100) NOT NULL,
    is_wheelchair_access_needed BOOLEAN DEFAULT FALSE,
    other_details TEXT,
    FOREIGN KEY (enquiry_id) REFERENCES enquiries(enquiry_id) ON DELETE CASCADE
);

-- Films table (from Films.java)
CREATE TABLE films (
    film_id INT AUTO_INCREMENT PRIMARY KEY,
    film_name VARCHAR(100) NOT NULL,
    film_duration DOUBLE NOT NULL,
    film_cost DOUBLE NOT NULL,
    status ENUM('WATCHED', 'NOT_WATCHED', 'BOOKED') NOT NULL DEFAULT 'NOT_WATCHED'
);

-- Film schedule (from FilmBooking.java)
CREATE TABLE film_schedule (
    schedule_id INT AUTO_INCREMENT PRIMARY KEY,
    film_id INT NOT NULL,
    scheduled_date VARCHAR(20) NOT NULL,  -- Stored as string per requirements
    FOREIGN KEY (film_id) REFERENCES films(film_id)
);

-- Events table (from GroupBookingManager.java)
CREATE TABLE events (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    event_name VARCHAR(100) NOT NULL,
    event_type ENUM('FILM', 'MEETING', 'REHEARSAL', 'SHOW') NOT NULL,
    venue ENUM('MAIN_HALL', 'SMALL_HALL', 'MEETING_ROOM', 'REHEARSAL_SPACE') NOT NULL,
    base_price DECIMAL(10,2) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE
);

-- Calendar/Bookings table (from RoomBookings.java)
CREATE TABLE bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_reference VARCHAR(20) NOT NULL UNIQUE,
    event_id INT NULL,
    enquiry_id INT NULL,
    room_type ENUM('GREEN_ROOM', 'BRONTE_BOARDROOM', 'DICKENS_DEN', 
                  'POE_PARLOR', 'GLOBE_ROOM', 'CHEKHOV_CHAMBER') NULL,
    layout ENUM('CLASSROOM', 'BOARDROOM', 'PRESENTATION') NULL,
    booking_date VARCHAR(20) NOT NULL,
    start_time VARCHAR(20) NOT NULL,
    end_time VARCHAR(20) NOT NULL,
    duration ENUM('HOUR', 'HALF_DAY', 'ALL_DAY', 'ALL_WEEK') NOT NULL,
    client_id INT NOT NULL,
    total_cost DECIMAL(10,2) NOT NULL,
    status ENUM('CONFIRMED', 'PENDING', 'CANCELLED') NOT NULL DEFAULT 'CONFIRMED',
    FOREIGN KEY (event_id) REFERENCES events(event_id),
    FOREIGN KEY (enquiry_id) REFERENCES enquiries(enquiry_id),
    FOREIGN KEY (client_id) REFERENCES clients(client_id)
);

-- Tickets table (from TicketManager.java) - Modified to include FOL information
CREATE TABLE tickets (
    ticket_id VARCHAR(20) PRIMARY KEY,
    booking_id VARCHAR(20) NOT NULL,
    event_id INT NOT NULL,
    booking_name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    is_wheelchair_access_needed BOOLEAN DEFAULT FALSE,
    client_id INT NOT NULL,
    is_fol_ticket BOOLEAN DEFAULT FALSE,
    fol_member_id INT NULL,
    FOREIGN KEY (event_id) REFERENCES events(event_id),
    FOREIGN KEY (client_id) REFERENCES clients(client_id),
    FOREIGN KEY (fol_member_id) REFERENCES fol_members(member_id)
);

-- Transactions table (from Transaction.java)
CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY,
    client_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    transaction_date DATE NOT NULL,
    booking_date VARCHAR(20) NOT NULL,
    booking_reference VARCHAR(20) NOT NULL,
    FOREIGN KEY (client_id) REFERENCES clients(client_id),
    FOREIGN KEY (booking_reference) REFERENCES bookings(booking_reference)
);

-- Promotions table (from Promo.java)
CREATE TABLE promotions (
    promo_id INT AUTO_INCREMENT PRIMARY KEY,
    promo_code VARCHAR(20) NOT NULL UNIQUE,
    discount_percentage DECIMAL(5,2) NOT NULL,
    valid_from DATE NOT NULL,
    valid_to DATE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    institution_id INT NULL,
    is_fol_exclusive BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (institution_id) REFERENCES institutions(institution_id)
);

-- FOL emails table (for promotional emails)
CREATE TABLE fol_emails (
    email_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE,
    member_id INT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (member_id) REFERENCES fol_members(member_id)
);

-- Film Financial Reports (Ticket Revenue vs Film Cost)
CREATE TABLE film_financial_reports (
    report_id INT AUTO_INCREMENT PRIMARY KEY,
    film_id INT NOT NULL,
    report_date DATE NOT NULL,
    total_ticket_revenue DECIMAL(12,2) NOT NULL,
    total_film_cost DECIMAL(12,2) NOT NULL,
    profit_loss DECIMAL(12,2) GENERATED ALWAYS AS (total_ticket_revenue - total_film_cost) STORED,
    tickets_sold INT NOT NULL,
    FOREIGN KEY (film_id) REFERENCES films(film_id)
);

-- FOL Membership vs Ticket Sales Reports
CREATE TABLE fol_ticket_reports (
    report_id INT AUTO_INCREMENT PRIMARY KEY,
    report_period VARCHAR(20) NOT NULL, -- e.g., "2023-Q1", "2023-10"
    total_tickets_sold INT NOT NULL,
    fol_tickets_sold INT NOT NULL,
    fol_member_count INT NOT NULL,
    fol_conversion_rate DECIMAL(5,2) GENERATED ALWAYS AS 
        (CASE WHEN total_tickets_sold = 0 THEN 0 
              ELSE (fol_tickets_sold * 100.0 / total_tickets_sold) 
         END) STORED,
    report_date DATE NOT NULL
);

-- Indexes for better performance on reporting queries
CREATE INDEX idx_tickets_client ON tickets(client_id);
CREATE INDEX idx_tickets_fol ON tickets(fol_member_id);
CREATE INDEX idx_bookings_client ON bookings(client_id);
CREATE INDEX idx_films_status ON films(status);
CREATE INDEX idx_transactions_date ON transactions(transaction_date);