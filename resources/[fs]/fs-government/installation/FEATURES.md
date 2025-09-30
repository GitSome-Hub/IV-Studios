# 📋 FS-Government - Complete Features Guide

This document provides detailed information about every feature, function, and capability of the FS-Government system.

## 📖 Table of Contents

- [🏢 Core Government Functions](#-core-government-functions)
- [⚖️ Legal & Administrative System](#️-legal--administrative-system)
- [💰 Economic Management](#-economic-management)
- [🛡️ Security & Surveillance](#️-security--surveillance)
- [👥 Employee Management](#-employee-management)
- [🎛️ Configuration System](#️-configuration-system)
- [📱 User Interface](#-user-interface)
- [🔐 Permission System](#-permission-system)
- [📊 Database Management](#-database-management)

---

## 🏢 Core Government Functions

### 👮 Player Interaction System

#### **Player Search**
- **Permission Required**: `search_players`
- **Function**: Search nearby players for contraband and items
- **Features**:
  - Automatic inventory detection (ESX/QBCore/QBox)
  - Real-time item display and quantities
  - Notification system for both officer and target
  - Distance-based targeting system

#### **Handcuff System**
- **Permission Required**: `handcuff`
- **Function**: Restrain or release players
- **Features**:
  - Toggle handcuff/uncuff functionality
  - Visual feedback for both parties
  - Persistent state tracking
  - Anti-exploit protection

#### **Identity Verification**
- **Permission Required**: `basic_access`
- **Function**: Check player identity and information
- **Features**:
  - Full character information display
  - Criminal record integration
  - Job and rank information
  - Contact details and personal data

### 🔫 Armory & Equipment

#### **Weapon Management**
- **Permission Required**: `armory_access`
- **Function**: Access government weapons and equipment
- **Features**:
  - Configurable weapon catalog
  - Rank-based weapon restrictions
  - Automatic inventory integration
  - Usage tracking and logging

#### **Equipment Shop**
- **Permission Required**: `armory_access`
- **Function**: Purchase government equipment and items
- **Features**:
  - Grade-based pricing discounts
  - Inventory management integration
  - Purchase history tracking
  - Multi-framework compatibility

### 🚗 Vehicle Management

#### **Government Garage**
- **Permission Required**: `garage_access`
- **Function**: Spawn and manage official vehicles
- **Features**:
  - Configurable vehicle fleet
  - Automatic key assignment
  - Government license plates
  - Vehicle return and storage system

#### **Vehicle Customization**
- **Function**: Apply government liveries and modifications
- **Features**:
  - Official government paint schemes
  - Emergency lighting systems
  - Radio and equipment installation
  - Performance modifications

### 📋 License Management

#### **License Issuance**
- **Permission Required**: `license_management`
- **Function**: Issue various types of licenses and permits
- **Features**:
  - Driving licenses (all categories)
  - Weapon permits and concealed carry
  - Business and professional licenses
  - Custom permit types

#### **License Verification**
- **Function**: Check validity of existing licenses
- **Features**:
  - Real-time database lookup
  - Expiration date checking
  - Suspension and revocation status
  - License history tracking

---

## ⚖️ Legal & Administrative System

### 📜 Law Management

#### **Law Creation**
- **Permission Required**: `law_management`
- **Function**: Create and manage custom laws
- **Features**:
  - Rich text law content editor
  - Fine amount specification
  - Jail time settings
  - Category and classification system

#### **Law Enforcement**
- **Function**: Apply laws and issue penalties
- **Features**:
  - Automated fine calculation
  - Integration with billing systems
  - Jail time processing
  - Criminal record updates

### 🗳️ Election System

#### **Election Management**
- **Permission Required**: `elections`
- **Function**: Organize and run democratic elections
- **Features**:
  - Candidate registration system
  - Voting booth functionality
  - Real-time vote counting
  - Results announcement system

#### **Campaign System**
- **Function**: Support political campaigns
- **Features**:
  - Campaign message system
  - Candidate profile management
  - Public endorsement tracking
  - Election timeline management

### 📅 Appointment System

#### **Citizen Appointments**
- **Function**: Allow citizens to book government meetings
- **Features**:
  - Online appointment booking
  - Calendar integration
  - Automatic reminders
  - Status tracking (pending/approved/completed)

#### **Appointment Management**
- **Permission Required**: `appointment_management`
- **Function**: Manage citizen appointment requests
- **Features**:
  - Request approval/rejection
  - Meeting scheduling
  - Notes and follow-up system
  - Historical appointment records

### 📢 Communication System

#### **Public Announcements**
- **Permission Required**: `announcements`
- **Function**: Broadcast official messages
- **Features**:
  - Priority level system (low/normal/high/urgent)
  - Server-wide notifications
  - Persistent message storage
  - Scheduled announcement system

---

## 💰 Economic Management

### 💵 Taxation System

#### **Automated Tax Collection**
- **Function**: Collect various types of taxes automatically
- **Tax Types**:
  - **Salary Tax**: Automatic deduction from government employees
  - **Business Tax**: Regular business operation taxes
  - **Transaction Tax**: Sales and service taxes
  - **Property Tax**: Real estate and asset taxes

#### **Tax Configuration**
- **Features**:
  - Configurable tax rates per category
  - Exemption system for specific groups
  - Seasonal tax adjustments
  - Tax holiday scheduling

### 🏦 Budget Management

#### **Department Budgets**
- **Permission Required**: `budget_management`
- **Function**: Allocate and track departmental spending
- **Features**:
  - Configurable department list
  - Budget allocation per fiscal year
  - Spending tracking and limits
  - Automated reporting

#### **Fund Allocation**
- **Permission Required**: Based on config settings
- **Function**: Distribute funds to various departments
- **Features**:
  - Real-time budget checking
  - Approval workflow system
  - Transaction logging
  - Society integration (ESX/QBCore)

### 💰 Subsidy System

#### **Social Aid Programs**
- **Permission Required**: `subsidy_management`
- **Function**: Distribute financial aid to citizens
- **Features**:
  - Multiple subsidy types
  - Eligibility criteria checking
  - Approval workflow system
  - Payment processing

#### **Business Subsidies**
- **Function**: Support local businesses with financial aid
- **Features**:
  - Business qualification system
  - Industry-specific programs
  - Performance tracking
  - Economic impact analysis

### 📊 Financial Reporting

#### **Revenue Analysis**
- **Permission Required**: `financial_reporting`
- **Function**: Generate comprehensive financial reports
- **Features**:
  - Income and expense tracking
  - Tax collection reports
  - Budget utilization analysis
  - Trend and forecasting data

#### **Audit System**
- **Permission Required**: `business_audit`
- **Function**: Review business and government finances
- **Features**:
  - Automated compliance checking
  - Suspicious transaction detection
  - Audit trail generation
  - Regulatory reporting

---

## 🛡️ Security & Surveillance

### 🚨 DEFCON System

#### **Alert Level Management**
- **Permission Required**: `defcon`
- **Function**: Manage emergency alert levels
- **DEFCON Levels**:
  - **DEFCON 5**: Normal peacetime readiness
  - **DEFCON 4**: Increased intelligence watch
  - **DEFCON 3**: Increase in force readiness
  - **DEFCON 2**: Next step to nuclear war
  - **DEFCON 1**: Maximum readiness - imminent nuclear war

#### **Visual Effects**
- **Features**:
  - Screen color overlays per DEFCON level
  - Emergency sound alerts
  - UI indicator updates
  - Server-wide notifications

### 📹 Surveillance Network

#### **Camera System**
- **Permission Required**: `surveillance`
- **Function**: Access city surveillance cameras
- **Features**:
  - Multiple camera locations
  - Real-time viewing
  - Recording capabilities
  - Access logging system

#### **Monitoring Logs**
- **Function**: Track surveillance system usage
- **Features**:
  - Officer access logs
  - Viewing duration tracking
  - Camera-specific statistics
  - Security audit trails

### 🔍 Asset Management

#### **Asset Seizure**
- **Permission Required**: `seizure`
- **Function**: Confiscate vehicles, items, or money
- **Features**:
  - Multi-type asset support (vehicle/item/money)
  - Reason documentation
  - Return process system
  - Evidence management

#### **Evidence Tracking**
- **Function**: Maintain chain of custody for seized assets
- **Features**:
  - Unique evidence numbering
  - Officer assignment tracking
  - Status updates (seized/returned/destroyed)
  - Legal documentation

### 📋 Warrant System

#### **Warrant Issuance**
- **Permission Required**: `warrant_issue`
- **Function**: Issue official warrants for suspects
- **Features**:
  - Search warrant creation
  - Arrest warrant processing
  - Warrant execution tracking
  - Legal justification requirements

---

## 👥 Employee Management

### 👔 Personnel Administration

#### **Hiring System**
- **Permission Required**: `employee_management`
- **Function**: Recruit new government employees
- **Features**:
  - Application processing
  - Background check integration
  - Probationary period tracking
  - Onboarding workflow

#### **Promotion Management**
- **Function**: Advance employee ranks and responsibilities
- **Features**:
  - Merit-based promotion system
  - Performance evaluation tracking
  - Salary adjustment automation
  - Permission level updates

### 💼 Payroll System

#### **Salary Management**
- **Function**: Process employee compensation
- **Features**:
  - Automated payroll processing
  - Grade-based salary scales
  - Overtime calculation
  - Tax deduction handling

#### **Performance Tracking**
- **Function**: Monitor employee productivity and performance
- **Features**:
  - Duty time tracking
  - Activity logging
  - Performance metrics
  - Evaluation reports

---

## 🎛️ Configuration System

### ⚙️ Framework Settings

#### **Multi-Framework Support**
```lua
Config.Framework = 'auto' -- Auto-detect framework
-- Options: 'esx', 'qbcore', 'qbox', 'auto'
```

#### **Inventory Integration**
```lua
Config.Inventory = 'auto' -- Auto-detect inventory
-- Options: 'ox_inventory', 'qb-inventory', 'esx_inventory', 'auto'
```

### 🏢 Job Configuration

#### **Government Jobs**
```lua
Config.Government = {
    jobs = {
        'police',      -- Law enforcement
        'government',  -- Civil service
        'mayor'        -- Executive branch
    }
}
```

#### **Permission System**
```lua
permissions = {
    [0] = {'basic_access'},
    [1] = {'basic_access', 'search_players'},
    [6] = {'all'}  -- Full access
}
```

### 🏛️ Department Management

#### **Configurable Departments**
```lua
Config.Departments = {
    police = 'Police Department',
    ambulance = 'Medical Services',
    fire = 'Fire Department',
    government = 'City Government',
    public_works = 'Public Works',
    education = 'Education Department'
}
```

### 💰 Economic Settings

#### **Tax Configuration**
```lua
Config.Taxation = {
    enabled = true,
    rates = {
        salary = 0.15,      -- 15% salary tax
        business = 0.12,    -- 12% business tax
        vehicle = 0.08,     -- 8% vehicle tax
        property = 0.10     -- 10% property tax
    }
}
```

---

## 📱 User Interface

### 🎨 Design Philosophy

#### **Modern UI Components**
- **ox_lib Integration**: Native FiveM UI components
- **Responsive Design**: Works on all screen sizes
- **Accessibility**: Touch and keyboard friendly
- **Performance**: Optimized rendering and animations

#### **Color Schemes**
- **Professional Theme**: Government-appropriate colors
- **High Contrast**: Excellent readability
- **Status Indicators**: Color-coded system states
- **Brand Consistency**: Unified visual identity

### 🖱️ Interaction Methods

#### **Context Menus**
- **Right-click Interactions**: Quick access to functions
- **Nested Menu Structure**: Organized feature hierarchy
- **Search Functionality**: Find features quickly
- **Keyboard Shortcuts**: Power user efficiency

#### **Input Forms**
- **Validation Systems**: Prevent invalid data entry
- **Auto-completion**: Speed up data entry
- **Help Text**: Contextual assistance
- **Error Handling**: Clear error messaging

### 📊 Data Visualization

#### **Charts and Graphs**
- **Financial Reports**: Visual budget and spending data
- **Performance Metrics**: Employee and department statistics
- **Trend Analysis**: Historical data visualization
- **Real-time Updates**: Live data refresh

---

## 🔐 Permission System

### 🎯 Permission Categories

#### **Basic Access Permissions**
- `basic_access` - Core menu access
- `search_players` - Player search functionality
- `handcuff` - Handcuff/uncuff players

#### **Equipment Permissions**
- `armory_access` - Weapon and equipment access
- `garage_access` - Vehicle management
- `inventory_access` - Shared storage access

#### **Administrative Permissions**
- `employee_management` - Hire/fire/promote staff
- `announcements` - Public announcement system
- `surveillance` - Camera system access

#### **Legal Permissions**
- `license_management` - Issue and manage licenses
- `law_management` - Create and modify laws
- `warrant_issue` - Issue warrants and legal documents

#### **Economic Permissions**
- `taxation` - Tax system management
- `budget_management` - Budget allocation and tracking
- `subsidy_management` - Social aid programs
- `financial_reporting` - Access financial reports
- `business_audit` - Business compliance auditing

#### **Security Permissions**
- `defcon` - DEFCON level management
- `seizure` - Asset seizure capabilities
- `elections` - Election system management

#### **Special Permissions**
- `all` - Complete system access (highest level)

### 🏗️ Permission Structure

#### **Hierarchical System**
- **Grade 0**: Basic access only
- **Grade 1**: Basic + search capabilities
- **Grade 2**: Equipment access added
- **Grade 3**: License management
- **Grade 4**: Administrative functions
- **Grade 5**: Advanced operations
- **Grade 6**: Economic and security functions
- **Grade 7**: Full system access

#### **Custom Permission Sets**
```lua
-- Example custom permission configuration
permissions = {
    [0] = {'basic_access'},
    [1] = {'basic_access', 'search_players'},
    [2] = {'basic_access', 'search_players', 'handcuff'},
    [3] = {'basic_access', 'search_players', 'handcuff', 'armory_access'},
    -- ... continue building permissions by grade
    [7] = {'all'}  -- Full access
}
```

---

## 📊 Database Management

### 🗄️ Database Tables

#### **Employee & Personnel Tables**
- **`government_employees`**
  - Employee tracking and payroll information
  - Hiring dates, salaries, and performance data
  - Job assignments and grade history

#### **Legal & Compliance Tables**
- **`government_laws`**
  - Custom law definitions and penalties
  - Fine amounts and jail time specifications
  - Law status tracking (active/inactive/draft)

- **`government_elections`**
  - Election management and scheduling
  - Candidate registration and campaign data
  - Voting records and results

#### **Economic & Financial Tables**
- **`government_taxation`**
  - Tax collection records and history
  - Tax type classification and amounts
  - Taxpayer information and compliance

- **`government_budget`**
  - Department budget allocations
  - Spending tracking and limits
  - Fiscal year management

- **`government_transactions`**
  - Financial transaction logging
  - Income and expense categorization
  - Audit trail maintenance

- **`government_subsidies`**
  - Social aid and business subsidy records
  - Approval workflows and payment tracking
  - Recipient information and eligibility

#### **Security & Surveillance Tables**
- **`government_surveillance_logs`**
  - Camera access tracking
  - Officer viewing records
  - Security audit trails

- **`government_seizures`**
  - Asset seizure records
  - Evidence management and chain of custody
  - Return and destruction tracking

#### **Administrative Tables**
- **`government_appointments`**
  - Citizen appointment requests
  - Scheduling and status tracking
  - Meeting notes and outcomes

- **`government_announcements`**
  - Public announcement archive
  - Priority levels and distribution
  - Delivery confirmation tracking

- **`government_businesses`**
  - Business registration and licensing
  - Compliance monitoring
  - Tax rate assignments

- **`government_permits`**
  - Specialized permit management
  - Expiration tracking and renewals
  - Permit type categorization

- **`government_settings`**
  - System configuration storage
  - DEFCON levels and emergency settings
  - Tax rates and economic parameters

### 🔧 Database Features

#### **Auto-Initialization**
- **Table Creation**: All tables created automatically on resource start
- **Schema Updates**: Handles database migrations and updates
- **Default Data**: Populates essential configuration data
- **Error Recovery**: Repairs common database issues

#### **Performance Optimization**
- **Indexed Queries**: Optimized database indexes for fast lookups
- **Connection Pooling**: Efficient database connection management
- **Query Optimization**: Minimized database load and response times
- **Caching Systems**: Reduced database calls through intelligent caching

#### **Data Integrity**
- **Foreign Key Constraints**: Ensures referential integrity
- **Data Validation**: Server-side validation before database insertion
- **Backup Compatibility**: Designed for easy backup and restoration
- **Migration Support**: Handles version updates gracefully

---

## 🚀 Advanced Features

### 🔄 Integration Capabilities

#### **Framework Integration**
- **ESX Legacy**: Full compatibility with latest ESX systems
- **QBCore**: Native integration with QB framework features
- **QBox**: Complete support for QBox functionality
- **Custom Frameworks**: Extensible architecture for custom implementations

#### **External Resource Integration**
- **Billing Systems**: ESX billing, QBCore billing integration
- **Inventory Systems**: ox_inventory, qb-inventory, esx_inventory support
- **Society Systems**: ESX society, QBCore bossmenu integration
- **Identity Systems**: esx_identity, QBCore character system support

### ⚡ Performance Features

#### **Optimization Techniques**
- **Event-Driven Architecture**: Eliminates unnecessary polling loops
- **Lazy Loading**: Resources loaded only when needed
- **Memory Management**: Proper cleanup and garbage collection
- **Network Optimization**: Compressed data transmission

#### **Scalability**
- **Multi-Server Support**: Designed for large server networks
- **Load Balancing**: Efficient resource distribution
- **Concurrent Processing**: Multi-threaded operation support
- **Resource Monitoring**: Built-in performance tracking

### 🛡️ Security Features

#### **Anti-Exploit Measures**
- **Server-Side Validation**: All actions verified on server
- **SQL Injection Protection**: Parameterized queries only
- **Access Control Lists**: Multiple permission verification layers
- **Rate Limiting**: Prevents spam and abuse

#### **Audit Systems**
- **Action Logging**: Complete audit trail of all system actions
- **User Activity Tracking**: Monitor government employee activities
- **Security Alerts**: Automated notification of suspicious activities
- **Compliance Reporting**: Generate security and compliance reports

---

## 📞 Support & Resources

### 🆘 Troubleshooting

#### **Common Issues**
1. **Database Connection**: Ensure oxmysql is running before fs-government
2. **Permission Errors**: Check job configuration in Config.Government.jobs
3. **Menu Issues**: Verify ox_lib is properly installed and started
4. **Framework Detection**: Set Config.Framework manually if auto-detection fails

#### **Debug Commands**
```
gov_db_status     # Check database health and initialization status
gov_db_init       # Force database re-initialization
gov_debug_armory  # Test armory system functionality
```

### 📚 Documentation Standards

#### **Code Documentation**
- **Inline Comments**: Comprehensive code commenting
- **Function Documentation**: Parameter and return value descriptions
- **API Documentation**: Complete function and event reference
- **Change Logs**: Detailed version change tracking

#### **User Guides**
- **Installation Guide**: Step-by-step setup instructions
- **Configuration Guide**: Detailed configuration explanations
- **Admin Guide**: Administrative function documentation
- **User Manual**: End-user feature explanations

---

*This comprehensive features guide covers all aspects of the FS-Government system. For installation and quick start information, see the main [README.md](README.md) file.*