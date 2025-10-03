import javax.swing.*;
import javax.swing.table.TableRowSorter;
import java.awt.*;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ManagerView extends JFrame {
    // Database connection (you'll need to update these for your actual database)
    private static final String DB_URL = "jdbc:postgresql://localhost:5432/your_database";
    private static final String DB_USER = "your_username";
    private static final String DB_PASSWORD = "your_password";

    private JTabbedPane tabbedPane;

    public ManagerView() {
        setTitle("Manager Dashboard");
        setSize(800, 600);
        setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
        setLayout(new BorderLayout());

        // Create tabbed pane for different views
        tabbedPane = new JTabbedPane();

        // Add tabs for different manager views
        tabbedPane.addTab("Monthly Sales", createMonthlySalesPanel());
        tabbedPane.addTab("Top Customers", createTopCustomersPanel());

        add(tabbedPane, BorderLayout.CENTER);

        // Add refresh button
        JPanel buttonPanel = new JPanel();
        JButton refreshBtn = new JButton("Refresh Data");
        refreshBtn.addActionListener(e -> refreshAllData());
        buttonPanel.add(refreshBtn);

        add(buttonPanel, BorderLayout.SOUTH);

        setVisible(true);
    }

    private JPanel createMonthlySalesPanel() {
        JPanel panel = new JPanel(new BorderLayout());
        panel.setBorder(BorderFactory.createTitledBorder("Monthly Sales History"));

        // Sample data (replace with actual database query)
        String[] columnNames = { "Month", "Total Orders" };
        Object[][] sampleData = {
                { "2024-01", 45 },
                { "2024-02", 38 },
                { "2024-03", 52 },
                { "2024-04", 41 },
                { "2024-05", 47 }
        };

        JTable table = new JTable(sampleData, columnNames);
        table.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);

        JScrollPane scrollPane = new JScrollPane(table);

        // Add some statistics
        JPanel statsPanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
        JLabel totalLabel = new JLabel("Total Months: 5 | Average Orders: 44.6");
        statsPanel.add(totalLabel);

        panel.add(scrollPane, BorderLayout.CENTER);
        panel.add(statsPanel, BorderLayout.SOUTH);

        return panel;
    }

    private JPanel createTopCustomersPanel() {
        JPanel panel = new JPanel(new BorderLayout());
        panel.setBorder(BorderFactory.createTitledBorder("Top 10 Customers (Most Points)"));

        // Sample data (replace with actual database query)
        String[] columnNames = { "Customer ID", "First Name", "Last Name", "Points" };
        Object[][] sampleData = {
                { "1001", "John", "Smith", 2850 },
                { "1002", "Emily", "Johnson", 2320 },
                { "1003", "Michael", "Brown", 1980 },
                { "1004", "Sarah", "Davis", 1750 },
                { "1005", "David", "Wilson", 1620 },
                { "1006", "Lisa", "Miller", 1480 },
                { "1007", "Robert", "Garcia", 1350 },
                { "1008", "Jennifer", "Martinez", 1280 },
                { "1009", "William", "Anderson", 1150 },
                { "1010", "Jessica", "Taylor", 1050 }
        };

        JTable table = new JTable(sampleData, columnNames);
        table.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
        table.setRowSorter(new TableRowSorter<>(table.getModel()));

        JScrollPane scrollPane = new JScrollPane(table);

        // Add summary
        JPanel summaryPanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
        JLabel summaryLabel = new JLabel("Total Customers: 10 | Highest Points: 2,850");
        summaryPanel.add(summaryLabel);

        panel.add(scrollPane, BorderLayout.CENTER);
        panel.add(summaryPanel, BorderLayout.SOUTH);

        return panel;
    }

    private void refreshAllData() {
        // TODO: Implement actual database connection and queries
        JOptionPane.showMessageDialog(this,
                "Refresh functionality would connect to database and reload data",
                "Refresh",
                JOptionPane.INFORMATION_MESSAGE);
    }

    // Method to load monthly sales data from database
    private List<Object[]> loadMonthlySalesData() {
        List<Object[]> data = new ArrayList<>();
        String query = """
                SELECT
                    DATE_TRUNC('month', date)::DATE AS month_start,
                    COUNT(*) AS total_orders
                FROM transactions
                GROUP BY month_start
                ORDER BY month_start
                """;

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                PreparedStatement stmt = conn.prepareStatement(query);
                ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                data.add(new Object[] {
                        rs.getDate("month_start"),
                        rs.getInt("total_orders")
                });
            }
        } catch (SQLException e) {
            JOptionPane.showMessageDialog(this,
                    "Error loading monthly sales data: " + e.getMessage(),
                    "Database Error",
                    JOptionPane.ERROR_MESSAGE);
        }

        return data;
    }

    // Method to load top customers data from database
    private List<Object[]> loadTopCustomersData() {
        List<Object[]> data = new ArrayList<>();
        String query = """
                SELECT
                    customerId,
                    firstName,
                    lastName,
                    points
                FROM customerRewards
                ORDER BY points DESC
                LIMIT 10
                """;

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                PreparedStatement stmt = conn.prepareStatement(query);
                ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                data.add(new Object[] {
                        rs.getString("customerId"),
                        rs.getString(" firstName"),
                        rs.getString("lastName"),
                        rs.getInt("points")
                });
            }
        } catch (SQLException e) {
            JOptionPane.showMessageDialog(this,
                    "Error loading top customers data: " + e.getMessage(),
                    "Database Error",
                    JOptionPane.ERROR_MESSAGE);
        }

        return data;
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(ManagerView::new);
    }
}
