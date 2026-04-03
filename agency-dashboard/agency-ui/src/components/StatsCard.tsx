import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import type { LucideIcon } from "lucide-react"

interface StatsCardProps {
    title: string
    value: number
    subtitle: string
    icon: LucideIcon
    trend?: {
        value: number
        isPositive: boolean
    }
    colorClass: string
}

export function StatsCard({ title, value, subtitle, icon: Icon, trend, colorClass }: StatsCardProps) {
    return (
        <Card className="overflow-hidden border-l-4" style={{ borderLeftColor: colorClass }}>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground">
                    {title}
                </CardTitle>
                <div className="p-2 rounded-lg" style={{ backgroundColor: `${colorClass}15` }}>
                    <Icon className="h-4 w-4" style={{ color: colorClass }} />
                </div>
            </CardHeader>
            <CardContent>
                <div className="text-3xl font-bold text-foreground">{value}</div>
                <div className="flex items-center justify-between mt-1">
                    <p className="text-xs text-muted-foreground">{subtitle}</p>
                    {trend && (
                        <span className={`text-xs font-medium ${trend.isPositive ? 'text-success' : 'text-destructive'}`}>
                            {trend.isPositive ? "↑" : "↓"} {Math.abs(trend.value)}%
                        </span>
                    )}
                </div>
            </CardContent>
        </Card>
    )
}
