// Global state
let allReports = [];
let filteredReports = [];
let selectedReport = null;

// Initialize dashboard
document.addEventListener('DOMContentLoaded', async () => {
    console.log('Dashboard initializing...');
    initCharts();
    await loadReports();
    setupRealtimeSubscription();
});

// Load all reports from Supabase
async function loadReports() {
    try {
        const { data, error } = await supabase
            .from('reports')
            .select('*')
            .order('created_at', { ascending: false });

        if (error) throw error;

        allReports = data || [];
        filteredReports = allReports;

        updateStats();
        updateCharts(allReports);
        renderReportsTable();

        console.log(`Loaded ${allReports.length} reports`);
    } catch (error) {
        console.error('Error loading reports:', error);
        showError('Failed to load reports');
    }
}

// Update statistics cards
function updateStats() {
    const stats = {
        active: 0,
        pending: 0,
        resolved: 0,
        total: allReports.length
    };

    allReports.forEach(report => {
        const status = report.status || 'reported';
        if (status === 'reported' || status === 'in_progress') {
            stats.active++;
        } else if (status === 'acknowledged') {
            stats.pending++;
        } else if (status === 'resolved') {
            stats.resolved++;
        }
    });

    document.getElementById('activeCount').textContent = stats.active;
    document.getElementById('pendingCount').textContent = stats.pending;
    document.getElementById('resolvedCount').textContent = stats.resolved;
    document.getElementById('totalCount').textContent = stats.total;
}

// Render reports table
function renderReportsTable() {
    const tbody = document.getElementById('reportsTableBody');

    if (filteredReports.length === 0) {
        tbody.innerHTML = '<tr><td colspan="7" class="loading-cell">No reports found</td></tr>';
        return;
    }

    tbody.innerHTML = filteredReports.map(report => `
        <tr>
            <td><strong>#${report.id.substring(0, 8)}</strong></td>
            <td><span style="text-transform: capitalize;">${report.category || 'N/A'}</span></td>
            <td>${truncate(report.address || 'Unknown', 40)}</td>
            <td><span class="status-badge status-${report.status}">${formatStatus(report.status)}</span></td>
            <td>${report.upvotes || 0}</td>
            <td>${formatDate(report.created_at)}</td>
            <td>
                <button class="btn-action" onclick="viewReport('${report.id}')">View</button>
            </td>
        </tr>
    `).join('');
}

// Filter reports
function filterReports() {
    const statusFilter = document.getElementById('statusFilter').value;
    const categoryFilter = document.getElementById('categoryFilter').value;
    const searchQuery = document.getElementById('searchInput').value.toLowerCase();

    filteredReports = allReports.filter(report => {
        const matchesStatus = statusFilter === 'all' || report.status === statusFilter;
        const matchesCategory = categoryFilter === 'all' || report.category === categoryFilter;
        const matchesSearch = searchQuery === '' ||
            report.id.toLowerCase().includes(searchQuery) ||
            (report.address && report.address.toLowerCase().includes(searchQuery)) ||
            (report.description && report.description.toLowerCase().includes(searchQuery));

        return matchesStatus && matchesCategory && matchesSearch;
    });

    renderReportsTable();
}

// View report details
async function viewReport(reportId) {
    try {
        const { data, error } = await supabase
            .from('reports')
            .select('*')
            .eq('id', reportId)
            .single();

        if (error) throw error;

        selectedReport = data;
        showReportModal(data);
    } catch (error) {
        console.error('Error loading report:', error);
        showError('Failed to load report details');
    }
}

// Show report modal
function showReportModal(report) {
    const modal = document.getElementById('reportModal');
    const modalBody = document.getElementById('modalBody');

    modalBody.innerHTML = `
        <div class="detail-section">
            ${report.image_url ? `<img src="${report.image_url}" alt="Report image" class="report-image">` : ''}
        </div>

        <div class="detail-section">
            <div class="detail-label">Report ID</div>
            <div class="detail-value">#${report.id.substring(0, 8)}</div>
        </div>

        <div class="detail-section">
            <div class="detail-label">Category</div>
            <div class="detail-value" style="text-transform: capitalize;">${report.category || 'N/A'}</div>
        </div>

        <div class="detail-section">
            <div class="detail-label">Description</div>
            <div class="detail-value">${report.description || 'No description provided'}</div>
        </div>

        <div class="detail-section">
            <div class="detail-label">Location</div>
            <div class="detail-value">${report.address || 'Unknown location'}</div>
            <div class="detail-value" style="font-size: 12px; color: #757575;">
                Lat: ${report.latitude}, Lng: ${report.longitude}
            </div>
        </div>

        <div class="detail-section">
            <div class="detail-label">Current Status</div>
            <div class="detail-value">
                <span class="status-badge status-${report.status}">${formatStatus(report.status)}</span>
            </div>
        </div>

        <div class="detail-section">
            <div class="detail-label">Upvotes</div>
            <div class="detail-value">${report.upvotes || 0}</div>
        </div>

        <div class="detail-section">
            <div class="detail-label">Reported On</div>
            <div class="detail-value">${formatDate(report.created_at)}</div>
        </div>

        <div class="status-update-form">
            <h3 style="margin-bottom: 16px;">Update Status</h3>
            <form onsubmit="updateReportStatus(event, '${report.id}')">
                <div class="form-group">
                    <label class="form-label">New Status</label>
                    <select class="form-select" id="newStatus" required>
                        <option value="reported" ${report.status === 'reported' ? 'selected' : ''}>Reported</option>
                        <option value="acknowledged" ${report.status === 'acknowledged' ? 'selected' : ''}>Acknowledged</option>
                        <option value="in_progress" ${report.status === 'in_progress' ? 'selected' : ''}>In Progress</option>
                        <option value="resolved" ${report.status === 'resolved' ? 'selected' : ''}>Resolved</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Comment (Optional)</label>
                    <textarea class="form-textarea" id="statusComment" placeholder="Add a note about this status change..."></textarea>
                </div>
                <button type="submit" class="btn-submit">Update Status</button>
            </form>
        </div>
    `;

    modal.style.display = 'block';
}

// Update report status
async function updateReportStatus(event, reportId) {
    event.preventDefault();

    const newStatus = document.getElementById('newStatus').value;
    const comment = document.getElementById('statusComment').value;

    try {
        // Update report status
        const { error: updateError } = await supabase
            .from('reports')
            .update({
                status: newStatus,
                updated_at: new Date().toISOString()
            })
            .eq('id', reportId);

        if (updateError) throw updateError;

        // Add timeline event
        const { error: timelineError } = await supabase
            .from('timeline_events')
            .insert({
                report_id: reportId,
                status: newStatus,
                message: comment || `Status changed to ${formatStatus(newStatus)}`,
                updated_by: 'Agency Admin'
            });

        if (timelineError) console.warn('Timeline event error:', timelineError);

        // Refresh data
        await loadReports();
        closeModal();
        showSuccess('Status updated successfully!');
    } catch (error) {
        console.error('Error updating status:', error);
        showError('Failed to update status');
    }
}

// Close modal
function closeModal() {
    document.getElementById('reportModal').style.display = 'none';
    selectedReport = null;
}

// Setup real-time subscription
function setupRealtimeSubscription() {
    const subscription = supabase
        .channel('reports-changes')
        .on('postgres_changes',
            { event: '*', schema: 'public', table: 'reports' },
            (payload) => {
                console.log('Real-time update:', payload);
                loadReports(); // Reload data on any change
            }
        )
        .subscribe();

    console.log('Real-time subscription active');
}

// Refresh data manually
async function refreshData() {
    const btn = document.querySelector('.btn-refresh');
    btn.disabled = true;
    btn.innerHTML = '<span class="refresh-icon" style="display: inline-block; animation: spin 1s linear infinite;">🔄</span> Refreshing...';

    await loadReports();

    setTimeout(() => {
        btn.disabled = false;
        btn.innerHTML = '<span class="refresh-icon">🔄</span> Refresh';
    }, 1000);
}

// Utility functions
function formatStatus(status) {
    const statusMap = {
        'reported': 'Reported',
        'acknowledged': 'Acknowledged',
        'in_progress': 'In Progress',
        'resolved': 'Resolved'
    };
    return statusMap[status] || status;
}

function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    });
}

function truncate(str, length) {
    return str.length > length ? str.substring(0, length) + '...' : str;
}

function showSuccess(message) {
    alert('✅ ' + message);
}

function showError(message) {
    alert('❌ ' + message);
}

// Close modal when clicking outside
window.onclick = function (event) {
    const modal = document.getElementById('reportModal');
    if (event.target === modal) {
        closeModal();
    }
}

// Add spin animation for refresh
const style = document.createElement('style');
style.textContent = `
    @keyframes spin {
        from { transform: rotate(0deg); }
        to { transform: rotate(360deg); }
    }
`;
document.head.appendChild(style);
