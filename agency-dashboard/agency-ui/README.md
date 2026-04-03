# UrbanFix Agency Dashboard

A clean, data-focused agency dashboard built with React, TypeScript, and shadcn/ui components. Matches the UrbanFix mobile app's earth-tone color palette.

## 🎨 Design Philosophy

- **Earth-Tone Colors**: Forest green (#2D6A4F), sage green, warm sand, and terracotta
- **Clean & Professional**: No unnecessary gradients, focus on data and statistics
- **Data-Driven**: Charts and analytics for better decision making
- **Consistent**: Matches the Flutter mobile app's design language

## 📊 Features

### Analytics & Visualization
- **Status Distribution** - Pie chart showing report status breakdown
- **Category Analysis** - Bar chart of reports by category
- **7-Day Trend** - Line chart tracking report volume over time
- **Real-time Stats** - Live updating statistics cards

### Reports Management
- Advanced filtering by status and category
- Real-time search functionality
- Detailed report view with status updates
- Timeline event tracking

### Real-time Updates
- Supabase real-time subscriptions
- Automatic data refresh
- Manual refresh option

## 🚀 Quick Start

```bash
cd agency-ui
npm run dev
```

Visit http://localhost:5173

## 🎨 Color Palette

```css
Primary (Forest Green): #2D6A4F
Secondary (Sage Green): #52B788
Accent (Warm Sand): #D4A574
Error (Terracotta): #D64545
Success (Deep Green): #40916C
Warning (Golden Yellow): #E9C46A
```

## 📁 Project Structure

```
src/
├── components/
│   ├── ui/              # shadcn/ui components
│   ├── StatsCard.tsx    # Statistics card component
│   ├── Charts.tsx       # Data visualization charts
│   └── ReportDetailsDialog.tsx
├── lib/
│   ├── supabase.ts      # Supabase client
│   └── utils.ts         # Utilities
├── App.tsx              # Main dashboard
└── index.css            # Global styles
```

## 🛠️ Tech Stack

- React 18 + TypeScript
- Vite
- shadcn/ui components
- Tailwind CSS
- Recharts for data visualization
- Supabase for backend

## 📈 Charts & Analytics

### Status Distribution (Pie Chart)
Shows breakdown of reports by status with color coding

### Category Analysis (Bar Chart)
Displays number of reports per category

### 7-Day Trend (Line Chart)
Tracks total reports and resolved reports over the last week

## 🎯 Key Components

### StatsCard
Clean card design with left border accent color, icon, and optional trend indicator

### Charts
Three-chart layout showing different data perspectives

### ReportDetailsDialog
Full report information with status update capability

---

**Built to match UrbanFix mobile app design** 🌿
