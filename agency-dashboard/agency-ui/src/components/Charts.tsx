import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, PieChart, Pie, Cell, LineChart, Line } from 'recharts'
import type { Report } from "@/lib/supabase"

interface ChartsProps {
    reports: Report[]
}

const COLORS = {
    reported: '#D64545', // Terracotta Red
    acknowledged: '#E9C46A', // Golden Yellow
    in_progress: '#52B788', // Sage Green
    resolved: '#40916C', // Deep Green
}

const CATEGORY_COLORS = {
    pothole: '#D64545',
    garbage: '#E9C46A',
    streetlight: '#D4A574',
    'water leakage': '#52B788',
    'road damage': '#2D6A4F',
    other: '#6C757D',
}

export function Charts({ reports }: ChartsProps) {
    // Status distribution data
    const statusData = [
        { name: 'Reported', value: reports.filter(r => r.status === 'reported').length, color: COLORS.reported },
        { name: 'Acknowledged', value: reports.filter(r => r.status === 'acknowledged').length, color: COLORS.acknowledged },
        { name: 'In Progress', value: reports.filter(r => r.status === 'in_progress').length, color: COLORS.in_progress },
        { name: 'Resolved', value: reports.filter(r => r.status === 'resolved').length, color: COLORS.resolved },
    ].filter(item => item.value > 0)

    // Category distribution data
    const categoryData = Object.entries(
        reports.reduce((acc, report) => {
            const cat = report.category || 'other'
            acc[cat] = (acc[cat] || 0) + 1
            return acc
        }, {} as Record<string, number>)
    ).map(([name, value]) => ({
        name: name.charAt(0).toUpperCase() + name.slice(1),
        value,
        color: CATEGORY_COLORS[name as keyof typeof CATEGORY_COLORS] || CATEGORY_COLORS.other
    }))

    // Trend data (last 7 days)
    const getLast7Days = () => {
        const days = []
        for (let i = 6; i >= 0; i--) {
            const date = new Date()
            date.setDate(date.getDate() - i)
            days.push(date.toISOString().split('T')[0])
        }
        return days
    }

    const trendData = getLast7Days().map(date => {
        const dayReports = reports.filter(r => r.created_at.startsWith(date))
        return {
            date: new Date(date).toLocaleDateString('en-US', { month: 'short', day: 'numeric' }),
            reports: dayReports.length,
            resolved: dayReports.filter(r => r.status === 'resolved').length,
        }
    })

    return (
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3 mb-8">
            {/* Status Distribution */}
            <Card>
                <CardHeader>
                    <CardTitle className="text-base font-semibold">Status Distribution</CardTitle>
                </CardHeader>
                <CardContent>
                    <ResponsiveContainer width="100%" height={200}>
                        <PieChart>
                            <Pie
                                data={statusData}
                                cx="50%"
                                cy="50%"
                                innerRadius={50}
                                outerRadius={80}
                                paddingAngle={2}
                                dataKey="value"
                            >
                                {statusData.map((entry, index) => (
                                    <Cell key={`cell-${index}`} fill={entry.color} />
                                ))}
                            </Pie>
                            <Tooltip />
                        </PieChart>
                    </ResponsiveContainer>
                    <div className="mt-4 space-y-2">
                        {statusData.map((item, index) => (
                            <div key={index} className="flex items-center justify-between text-sm">
                                <div className="flex items-center gap-2">
                                    <div className="w-3 h-3 rounded-full" style={{ backgroundColor: item.color }} />
                                    <span className="text-muted-foreground">{item.name}</span>
                                </div>
                                <span className="font-medium">{item.value}</span>
                            </div>
                        ))}
                    </div>
                </CardContent>
            </Card>

            {/* Category Distribution */}
            <Card>
                <CardHeader>
                    <CardTitle className="text-base font-semibold">Reports by Category</CardTitle>
                </CardHeader>
                <CardContent>
                    <ResponsiveContainer width="100%" height={200}>
                        <BarChart data={categoryData}>
                            <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" />
                            <XAxis dataKey="name" tick={{ fontSize: 12 }} angle={-45} textAnchor="end" height={80} />
                            <YAxis tick={{ fontSize: 12 }} />
                            <Tooltip />
                            <Bar dataKey="value" radius={[8, 8, 0, 0]}>
                                {categoryData.map((entry, index) => (
                                    <Cell key={`cell-${index}`} fill={entry.color} />
                                ))}
                            </Bar>
                        </BarChart>
                    </ResponsiveContainer>
                </CardContent>
            </Card>

            {/* 7-Day Trend */}
            <Card>
                <CardHeader>
                    <CardTitle className="text-base font-semibold">7-Day Trend</CardTitle>
                </CardHeader>
                <CardContent>
                    <ResponsiveContainer width="100%" height={200}>
                        <LineChart data={trendData}>
                            <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" />
                            <XAxis dataKey="date" tick={{ fontSize: 12 }} />
                            <YAxis tick={{ fontSize: 12 }} />
                            <Tooltip />
                            <Line type="monotone" dataKey="reports" stroke="#2D6A4F" strokeWidth={2} dot={{ fill: '#2D6A4F' }} />
                            <Line type="monotone" dataKey="resolved" stroke="#40916C" strokeWidth={2} dot={{ fill: '#40916C' }} />
                        </LineChart>
                    </ResponsiveContainer>
                    <div className="mt-4 flex items-center justify-center gap-4 text-sm">
                        <div className="flex items-center gap-2">
                            <div className="w-3 h-3 rounded-full bg-[#2D6A4F]" />
                            <span className="text-muted-foreground">Total Reports</span>
                        </div>
                        <div className="flex items-center gap-2">
                            <div className="w-3 h-3 rounded-full bg-[#40916C]" />
                            <span className="text-muted-foreground">Resolved</span>
                        </div>
                    </div>
                </CardContent>
            </Card>
        </div>
    )
}
