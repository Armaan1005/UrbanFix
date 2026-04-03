// Charts Configuration
let categoryChart, statusChart;

function initCharts() {
    // Category Chart
    const categoryCtx = document.getElementById('categoryChart').getContext('2d');
    categoryChart = new Chart(categoryCtx, {
        type: 'doughnut',
        data: {
            labels: [],
            datasets: [{
                data: [],
                backgroundColor: [
                    '#FF6384',
                    '#36A2EB',
                    '#FFCE56',
                    '#4BC0C0',
                    '#9966FF',
                    '#FF9F40'
                ],
                borderWidth: 0
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                legend: {
                    position: 'bottom',
                    labels: {
                        padding: 15,
                        font: {
                            size: 12
                        }
                    }
                }
            }
        }
    });

    // Status Chart
    const statusCtx = document.getElementById('statusChart').getContext('2d');
    statusChart = new Chart(statusCtx, {
        type: 'bar',
        data: {
            labels: ['Reported', 'Acknowledged', 'In Progress', 'Resolved'],
            datasets: [{
                label: 'Reports',
                data: [0, 0, 0, 0],
                backgroundColor: [
                    '#F44336',
                    '#FF9800',
                    '#2196F3',
                    '#4CAF50'
                ],
                borderWidth: 0,
                borderRadius: 8
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                legend: {
                    display: false
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: {
                        stepSize: 1
                    }
                }
            }
        }
    });
}

function updateCharts(reports) {
    // Update Category Chart
    const categoryCounts = {};
    reports.forEach(report => {
        const category = report.category || 'other';
        categoryCounts[category] = (categoryCounts[category] || 0) + 1;
    });

    categoryChart.data.labels = Object.keys(categoryCounts);
    categoryChart.data.datasets[0].data = Object.values(categoryCounts);
    categoryChart.update();

    // Update Status Chart
    const statusCounts = {
        reported: 0,
        acknowledged: 0,
        in_progress: 0,
        resolved: 0
    };

    reports.forEach(report => {
        const status = report.status || 'reported';
        if (statusCounts.hasOwnProperty(status)) {
            statusCounts[status]++;
        }
    });

    statusChart.data.datasets[0].data = [
        statusCounts.reported,
        statusCounts.acknowledged,
        statusCounts.in_progress,
        statusCounts.resolved
    ];
    statusChart.update();
}
