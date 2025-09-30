# 🏛️ FS-Government - Complete Government Management System

A comprehensive and advanced government management script for FiveM servers with full framework compatibility (ESX, QBCore, QBox) and modern UI integration.

## 🚀 Quick Start

1. **Install Dependencies** - Ensure `ox_lib` and `oxmysql` are installed and running
2. **Add Resource** - Place `fs-government` in your resources folder
3. **Configure** - Edit `config.lua` to match your server setup
4. **Start Resource** - Add `start fs-government` to your server.cfg
5. **Auto-Setup** - Database tables and settings are created automatically on first start

**That's it!** No manual SQL imports required - everything is handled automatically.

## 📋 Key Features Overview

### 🏢 **Core Government Functions**
- Complete player interaction system (search, handcuff, identity checks)
- Professional armory and equipment management
- Advanced licensing and permit system
- Government vehicle fleet management
- Employee management and payroll system

### ⚖️ **Legal & Administrative**
- Dynamic law creation and enforcement system
- Election management with real-time voting
- Citizen appointment booking system
- Official announcement broadcasting
- Business registration and compliance tracking

### 💰 **Economic Management**
- Automated taxation system (salary, business, transaction taxes)
- Department budget allocation and tracking
- Subsidy and social aid distribution
- Financial reporting and audit trails
- Investment and fund management

### 🛡️ **Security & Surveillance**
- DEFCON alert system (5 levels with visual effects)
- Surveillance camera network access
- Asset seizure and evidence management
- Warrant issuance and tracking system
- Criminal record maintenance

## 🔧 Framework Compatibility

| Framework | Support | Features |
|-----------|---------|----------|
| **ESX Legacy** | ✅ Full | All features supported |
| **QBCore** | ✅ Full | Complete integration |
| **QBox** | ✅ Full | Native compatibility |

### Auto-Detection
The script automatically detects your framework - no manual configuration needed!

## 📊 Database System

### 🎯 **Auto-Import Technology**
- **16 Database Tables** created automatically
- **Zero Manual Setup** - no SQL file imports required
- **Migration Support** - handles updates and schema changes
- **Error Recovery** - built-in repair and status checking

### 🛠️ **Management Commands**
```
gov_db_status    # Check database health and table status
gov_db_init      # Force database re-initialization
```

## ⚙️ Configuration

### 📂 **Easy Setup**
All configuration is centralized in `config.lua`:

```lua
-- Framework (auto-detected)
Config.Framework = 'auto'

-- Government Jobs
Config.Government = {
    jobs = {'police', 'government'},
    permissions = {
        [0] = {'basic_access'},
        [6] = {'all'}
    }
}

-- Configurable Departments
Config.Departments = {
    police = 'Police Department',
    ambulance = 'Medical Services',
    fire = 'Fire Department'
}
```

### 🎛️ **Customizable Features**
- **Job Permissions** - Grade-based access control
- **Department Management** - Add/remove departments easily
- **Tax Rates** - Adjust all taxation percentages
- **UI Settings** - Customize colors, positions, and styles

## 🎮 Usage Guide

### 👮 **For Government Employees**
1. **Go On Duty** - Use `/gov` or interact at government building
2. **Access Functions** - All features available through intuitive menus
3. **Use Permissions** - Features unlock based on your job grade

### 🏛️ **For Administrators**
1. **Configure Jobs** - Set which jobs can access government functions
2. **Manage Permissions** - Assign specific functions to job grades
3. **Monitor Activity** - View logs and reports through the system

### 👥 **For Citizens**
1. **Request Appointments** - Book meetings with government officials
2. **Apply for Permits** - Submit permit applications
3. **Receive Services** - Access government aid and subsidies

## 📱 User Interface

### 🎨 **Modern Design**
- **ox_lib Integration** - Native FiveM UI components
- **Responsive Menus** - Clean, intuitive interfaces
- **Real-time Updates** - Live data refresh and notifications
- **Mobile-Friendly** - Touch-screen compatible design

### 🖥️ **Menu System**
- **Context Menus** - Right-click interactions
- **Input Dialogs** - Form-based data entry
- **Progress Bars** - Visual feedback for long operations
- **Notifications** - Success/error message system

## 🔐 Security Features

### 🛡️ **Permission System**
- **Grade-Based Access** - Hierarchical permission structure
- **Function-Specific** - Granular control over individual features
- **Audit Trail** - Complete logging of all administrative actions

### 🔍 **Anti-Exploit**
- **Server-Side Validation** - All actions verified on server
- **SQL Injection Protection** - Parameterized queries only
- **Access Control** - Multiple permission checks per function

## 📈 Performance

### ⚡ **Optimized Code**
- **Efficient Database Queries** - Minimal server impact
- **Event-Driven Architecture** - No unnecessary loops
- **Memory Management** - Proper cleanup and garbage collection
- **Network Optimization** - Compressed data transmission

### 📊 **Monitoring**
- **Built-in Debugging** - Comprehensive logging system
- **Performance Metrics** - Resource usage tracking
- **Error Handling** - Graceful failure recovery

## 🆘 Support & Documentation

### 📚 **Documentation**
- **README.md** - Quick start and overview (this file)
- **FEATURES.md** - Detailed feature documentation

### 🐛 **Troubleshooting**
1. **Check Dependencies** - Ensure ox_lib and oxmysql are running
2. **Verify Database** - Use `gov_db_status` command
3. **Check Logs** - Review server console for errors
4. **Test Permissions** - Verify job/grade configuration

*For detailed feature documentation, see [FEATURES.md](FEATURES.md)*