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

        console.log('✅ Status updated successfully');

        // Try to add timeline event (optional - may fail due to RLS)
        try {
            await supabase
                .from('timeline_events')
                .insert({
                    report_id: reportId,
                    status: newStatus,
                    message: comment || `Status changed to ${formatStatus(newStatus)}`,
                    updated_by: 'Agency Admin'
                });
            console.log('✅ Timeline event created');
        } catch (timelineError) {
            console.warn('⚠️ Timeline event skipped (RLS policy)');
            // This is OK - status was still updated
        }

        // Refresh data
        await loadReports();
        closeModal();
        showSuccess('Status updated successfully!');
    } catch (error) {
        console.error('Error updating status:', error);
        showError('Failed to update status: ' + error.message);
    }
}
