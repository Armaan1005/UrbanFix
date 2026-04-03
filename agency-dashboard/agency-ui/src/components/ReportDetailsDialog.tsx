import { useState } from "react"
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogHeader,
    DialogTitle,
} from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { supabase, type Report } from "@/lib/supabase"
import { MapPin, Calendar, ThumbsUp, Image as ImageIcon } from "lucide-react"

interface ReportDetailsDialogProps {
    report: Report | null
    open: boolean
    onOpenChange: (open: boolean) => void
    onUpdate: () => void
}

export function ReportDetailsDialog({ report, open, onOpenChange, onUpdate }: ReportDetailsDialogProps) {
    const [newStatus, setNewStatus] = useState<string>("")
    const [isUpdating, setIsUpdating] = useState(false)

    if (!report) return null

    const handleStatusUpdate = async () => {
        if (!newStatus || newStatus === report.status) return

        setIsUpdating(true)
        try {
            const { error: updateError } = await supabase
                .from('reports')
                .update({
                    status: newStatus,
                    updated_at: new Date().toISOString()
                })
                .eq('id', report.id)

            if (updateError) throw updateError

            // Add timeline event
            await supabase
                .from('timeline_events')
                .insert({
                    report_id: report.id,
                    status: newStatus,
                    message: `Status changed to ${formatStatus(newStatus)}`,
                    updated_by: 'Agency Admin'
                })

            onUpdate()
            onOpenChange(false)
        } catch (error) {
            console.error('Error updating status:', error)
            alert('Failed to update status')
        } finally {
            setIsUpdating(false)
        }
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

    const getStatusVariant = (status: string): "default" | "secondary" | "destructive" | "outline" | "success" | "warning" => {
        const variants: Record<string, "default" | "secondary" | "destructive" | "outline" | "success" | "warning"> = {
            'reported': 'destructive',
            'acknowledged': 'warning',
            'in_progress': 'default',
            'resolved': 'success'
        }
        return variants[status] || 'default'
    }

    return (
        <Dialog open={open} onOpenChange={onOpenChange}>
            <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
                <DialogHeader>
                    <DialogTitle className="text-2xl">Report Details</DialogTitle>
                    <DialogDescription>
                        ID: #{report.id.substring(0, 8)}
                    </DialogDescription>
                </DialogHeader>

                <div className="space-y-6">
                    {/* Image */}
                    {report.image_url ? (
                        <div className="relative w-full h-64 rounded-lg overflow-hidden bg-muted">
                            <img
                                src={report.image_url}
                                alt="Report"
                                className="w-full h-full object-cover"
                            />
                        </div>
                    ) : (
                        <div className="relative w-full h-64 rounded-lg overflow-hidden bg-muted flex items-center justify-center">
                            <ImageIcon className="h-16 w-16 text-muted-foreground" />
                        </div>
                    )}

                    {/* Status Badge */}
                    <div className="flex items-center gap-2">
                        <span className="text-sm font-medium">Status:</span>
                        <Badge variant={getStatusVariant(report.status)}>
                            {formatStatus(report.status)}
                        </Badge>
                    </div>

                    {/* Category */}
                    <div>
                        <h3 className="text-sm font-medium text-muted-foreground mb-1">Category</h3>
                        <p className="text-base capitalize">{report.category}</p>
                    </div>

                    {/* Description */}
                    <div>
                        <h3 className="text-sm font-medium text-muted-foreground mb-1">Description</h3>
                        <p className="text-base">{report.description || 'No description provided'}</p>
                    </div>

                    {/* Location */}
                    <div>
                        <h3 className="text-sm font-medium text-muted-foreground mb-1 flex items-center gap-1">
                            <MapPin className="h-4 w-4" />
                            Location
                        </h3>
                        <p className="text-base">{report.address || 'Unknown location'}</p>
                        <p className="text-xs text-muted-foreground mt-1">
                            Lat: {report.latitude}, Lng: {report.longitude}
                        </p>
                    </div>

                    {/* Metadata */}
                    <div className="grid grid-cols-2 gap-4">
                        <div>
                            <h3 className="text-sm font-medium text-muted-foreground mb-1 flex items-center gap-1">
                                <ThumbsUp className="h-4 w-4" />
                                Upvotes
                            </h3>
                            <p className="text-base font-semibold">{report.upvotes || 0}</p>
                        </div>
                        <div>
                            <h3 className="text-sm font-medium text-muted-foreground mb-1 flex items-center gap-1">
                                <Calendar className="h-4 w-4" />
                                Reported On
                            </h3>
                            <p className="text-base">
                                {new Date(report.created_at).toLocaleDateString('en-US', {
                                    year: 'numeric',
                                    month: 'short',
                                    day: 'numeric'
                                })}
                            </p>
                        </div>
                    </div>

                    {/* Status Update */}
                    <div className="border-t pt-6">
                        <h3 className="text-lg font-semibold mb-4">Update Status</h3>
                        <div className="space-y-4">
                            <Select value={newStatus || report.status} onValueChange={setNewStatus}>
                                <SelectTrigger>
                                    <SelectValue placeholder="Select new status" />
                                </SelectTrigger>
                                <SelectContent>
                                    <SelectItem value="reported">Reported</SelectItem>
                                    <SelectItem value="acknowledged">Acknowledged</SelectItem>
                                    <SelectItem value="in_progress">In Progress</SelectItem>
                                    <SelectItem value="resolved">Resolved</SelectItem>
                                </SelectContent>
                            </Select>
                            <Button
                                onClick={handleStatusUpdate}
                                disabled={isUpdating || !newStatus || newStatus === report.status}
                                className="w-full"
                            >
                                {isUpdating ? 'Updating...' : 'Update Status'}
                            </Button>
                        </div>
                    </div>
                </div>
            </DialogContent>
        </Dialog>
    )
}
