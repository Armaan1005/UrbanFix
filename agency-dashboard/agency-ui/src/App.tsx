import { useEffect, useState } from 'react'
import { supabase, type Report } from './lib/supabase'
import { StatsCard } from './components/StatsCard'
import { Charts } from './components/Charts'
import { ReportDetailsDialog } from './components/ReportDetailsDialog'
import { Button } from './components/ui/button'
import { Input } from './components/ui/input'
import { Badge } from './components/ui/badge'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from './components/ui/table'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from './components/ui/select'
import {
  AlertCircle,
  Clock,
  CheckCircle2,
  BarChart3,
  RefreshCw,
  Search,
  Leaf,
  Loader2,
} from 'lucide-react'
import './index.css'

function App() {
  const [reports, setReports] = useState<Report[]>([])
  const [filteredReports, setFilteredReports] = useState<Report[]>([])
  const [selectedReport, setSelectedReport] = useState<Report | null>(null)
  const [isDialogOpen, setIsDialogOpen] = useState(false)
  const [isLoading, setIsLoading] = useState(true)
  const [isRefreshing, setIsRefreshing] = useState(false)

  // Filters
  const [statusFilter, setStatusFilter] = useState('all')
  const [categoryFilter, setCategoryFilter] = useState('all')
  const [searchQuery, setSearchQuery] = useState('')

  useEffect(() => {
    loadReports()
    setupRealtimeSubscription()
  }, [])

  useEffect(() => {
    filterReports()
  }, [reports, statusFilter, categoryFilter, searchQuery])

  const loadReports = async () => {
    try {
      const { data, error } = await supabase
        .from('reports')
        .select('*')
        .order('created_at', { ascending: false })

      if (error) throw error
      setReports(data || [])
    } catch (error) {
      console.error('Error loading reports:', error)
    } finally {
      setIsLoading(false)
      setIsRefreshing(false)
    }
  }

  const setupRealtimeSubscription = () => {
    const subscription = supabase
      .channel('reports-changes')
      .on('postgres_changes',
        { event: '*', schema: 'public', table: 'reports' },
        () => {
          loadReports()
        }
      )
      .subscribe()

    return () => {
      subscription.unsubscribe()
    }
  }

  const filterReports = () => {
    let filtered = reports

    if (statusFilter !== 'all') {
      filtered = filtered.filter(r => r.status === statusFilter)
    }

    if (categoryFilter !== 'all') {
      filtered = filtered.filter(r => r.category === categoryFilter)
    }

    if (searchQuery) {
      const query = searchQuery.toLowerCase()
      filtered = filtered.filter(r =>
        r.id.toLowerCase().includes(query) ||
        r.address?.toLowerCase().includes(query) ||
        r.description?.toLowerCase().includes(query)
      )
    }

    setFilteredReports(filtered)
  }

  const handleRefresh = () => {
    setIsRefreshing(true)
    loadReports()
  }

  const handleViewReport = (report: Report) => {
    setSelectedReport(report)
    setIsDialogOpen(true)
  }

  // Calculate stats
  const stats = {
    reported: reports.filter(r => r.status === 'reported').length,
    inProgress: reports.filter(r => r.status === 'in_progress').length,
    pending: reports.filter(r => r.status === 'acknowledged').length,
    resolved: reports.filter(r => r.status === 'resolved').length,
    total: reports.length,
  }

  const getStatusVariant = (status: string): "default" | "secondary" | "destructive" | "outline" | "success" | "warning" => {
    const variants: Record<string, "default" | "secondary" | "destructive" | "outline" | "success" | "warning"> = {
      'reported': 'destructive',
      'acknowledged': 'warning',
      'in_progress': 'secondary',
      'resolved': 'success'
    }
    return variants[status] || 'default'
  }

  const formatStatus = (status: string) => {
    const statusMap: Record<string, string> = {
      'reported': 'Reported',
      'acknowledged': 'Acknowledged',
      'in_progress': 'In Progress',
      'resolved': 'Resolved'
    }
    return statusMap[status] || status
  }

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="sticky top-0 z-40 w-full border-b bg-card/95 backdrop-blur supports-[backdrop-filter]:bg-card/60">
        <div className="container mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-primary/10 rounded-lg">
                <Leaf className="h-6 w-6 text-primary" />
              </div>
              <div>
                <h1 className="text-2xl font-bold text-foreground">
                  UrbanFix Agency Dashboard
                </h1>
                <p className="text-sm text-muted-foreground">Civic Issue Management & Analytics</p>
              </div>
            </div>
            <Button
              onClick={handleRefresh}
              disabled={isRefreshing}
              variant="outline"
              className="gap-2"
            >
              <RefreshCw className={`h-4 w-4 ${isRefreshing ? 'animate-spin' : ''}`} />
              Refresh
            </Button>
          </div>
        </div>
      </header>

      <main className="container mx-auto px-4 py-8">
        {/* Stats Grid */}
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-5 mb-8">
          <StatsCard
            title="Reported"
            value={stats.reported}
            subtitle="Newly reported"
            icon={AlertCircle}
            colorClass="#D64545"
          />
          <StatsCard
            title="In Progress"
            value={stats.inProgress}
            subtitle="Being worked on"
            icon={Loader2}
            colorClass="#52B788"
          />
          <StatsCard
            title="Pending Review"
            value={stats.pending}
            subtitle="Awaiting acknowledgment"
            icon={Clock}
            colorClass="#E9C46A"
          />
          <StatsCard
            title="Resolved"
            value={stats.resolved}
            subtitle="Successfully completed"
            icon={CheckCircle2}
            colorClass="#40916C"
          />
          <StatsCard
            title="Total Reports"
            value={stats.total}
            subtitle="All time"
            icon={BarChart3}
            colorClass="#2D6A4F"
          />
        </div>

        {/* Charts */}
        <Charts reports={reports} />

        {/* Reports Table */}
        <div className="bg-card rounded-xl shadow-sm border">
          <div className="p-6 border-b">
            <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
              <h2 className="text-xl font-semibold">Reports Management</h2>

              <div className="flex flex-col sm:flex-row gap-3">
                <Select value={statusFilter} onValueChange={setStatusFilter}>
                  <SelectTrigger className="w-full sm:w-[180px]">
                    <SelectValue placeholder="All Status" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="all">All Status</SelectItem>
                    <SelectItem value="reported">Reported</SelectItem>
                    <SelectItem value="acknowledged">Acknowledged</SelectItem>
                    <SelectItem value="in_progress">In Progress</SelectItem>
                    <SelectItem value="resolved">Resolved</SelectItem>
                  </SelectContent>
                </Select>

                <Select value={categoryFilter} onValueChange={setCategoryFilter}>
                  <SelectTrigger className="w-full sm:w-[180px]">
                    <SelectValue placeholder="All Categories" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="all">All Categories</SelectItem>
                    <SelectItem value="pothole">Pothole</SelectItem>
                    <SelectItem value="garbage">Garbage</SelectItem>
                    <SelectItem value="streetlight">Streetlight</SelectItem>
                    <SelectItem value="water leakage">Water Leakage</SelectItem>
                    <SelectItem value="road damage">Road Damage</SelectItem>
                    <SelectItem value="other">Other</SelectItem>
                  </SelectContent>
                </Select>

                <div className="relative">
                  <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                  <Input
                    placeholder="Search by ID or location..."
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    className="pl-9 w-full sm:w-[250px]"
                  />
                </div>
              </div>
            </div>
          </div>

          <div className="overflow-x-auto">
            {isLoading ? (
              <div className="flex items-center justify-center py-12">
                <RefreshCw className="h-8 w-8 animate-spin text-muted-foreground" />
              </div>
            ) : filteredReports.length === 0 ? (
              <div className="text-center py-12 text-muted-foreground">
                No reports found
              </div>
            ) : (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>ID</TableHead>
                    <TableHead>Category</TableHead>
                    <TableHead>Location</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead>Upvotes</TableHead>
                    <TableHead>Date</TableHead>
                    <TableHead>Actions</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {filteredReports.map((report) => (
                    <TableRow key={report.id}>
                      <TableCell className="font-medium">
                        #{report.id.substring(0, 8)}
                      </TableCell>
                      <TableCell className="capitalize">{report.category}</TableCell>
                      <TableCell className="max-w-[200px] truncate">
                        {report.address || 'Unknown'}
                      </TableCell>
                      <TableCell>
                        <Badge variant={getStatusVariant(report.status)}>
                          {formatStatus(report.status)}
                        </Badge>
                      </TableCell>
                      <TableCell>{report.upvotes || 0}</TableCell>
                      <TableCell>
                        {new Date(report.created_at).toLocaleDateString('en-US', {
                          month: 'short',
                          day: 'numeric',
                          year: 'numeric'
                        })}
                      </TableCell>
                      <TableCell>
                        <Button
                          size="sm"
                          onClick={() => handleViewReport(report)}
                        >
                          View
                        </Button>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            )}
          </div>
        </div>
      </main>

      {/* Report Details Dialog */}
      <ReportDetailsDialog
        report={selectedReport}
        open={isDialogOpen}
        onOpenChange={setIsDialogOpen}
        onUpdate={loadReports}
      />
    </div>
  )
}

export default App
