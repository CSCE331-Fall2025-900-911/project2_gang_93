import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.util.*;

public class OrderingSystem extends JFrame {
    private Map<String, Double> menuItems;
    private Map<String, Integer> cart;
    private DefaultListModel<String> cartModel;
    private JLabel totalLabel;

    public OrderingSystem() {
        setTitle("Ordering System");
        setSize(500, 400);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLayout(new BorderLayout());

        // Menu items
        menuItems = new LinkedHashMap<>();
        menuItems.put("Burger", 5.99);
        menuItems.put("Fries", 2.49);
        menuItems.put("Soda", 1.50);
        menuItems.put("Salad", 4.25);
        menuItems.put("Pizza", 7.99);

        cart = new HashMap<>();
        cartModel = new DefaultListModel<>();

        // ===== Menu Panel =====
        JPanel menuPanel = new JPanel();
        menuPanel.setLayout(new GridLayout(menuItems.size() + 1, 1));
        menuPanel.setBorder(BorderFactory.createTitledBorder("Menu"));

        for (String item : menuItems.keySet()) {
            JButton btn = new JButton(item + " - $" + String.format("%.2f", menuItems.get(item)));
            btn.addActionListener(e -> addToCart(item));
            menuPanel.add(btn);
        }

        // ===== Cart Panel =====
        JPanel cartPanel = new JPanel();
        cartPanel.setLayout(new BorderLayout());
        cartPanel.setBorder(BorderFactory.createTitledBorder("Cart"));

        JList<String> cartList = new JList<>(cartModel);
        JScrollPane scrollPane = new JScrollPane(cartList);
        cartPanel.add(scrollPane, BorderLayout.CENTER);

        totalLabel = new JLabel("Total: $0.00");
        cartPanel.add(totalLabel, BorderLayout.SOUTH);

        // ===== Buttons under Cart =====
        JPanel buttonPanel = new JPanel();
        JButton removeBtn = new JButton("Remove Selected");
        removeBtn.addActionListener(e -> {
            String selected = cartList.getSelectedValue();
            if (selected != null) {
                String itemName = selected.split(" x")[0];
                removeFromCart(itemName);
            }
        });

        JButton checkoutBtn = new JButton("Checkout");
        checkoutBtn.addActionListener(e -> checkout());

        buttonPanel.add(removeBtn);
        buttonPanel.add(checkoutBtn);
        cartPanel.add(buttonPanel, BorderLayout.NORTH);

        // Add panels to frame
        add(menuPanel, BorderLayout.WEST);
        add(cartPanel, BorderLayout.CENTER);

        setVisible(true);
    }

    private void addToCart(String item) {
        cart.put(item, cart.getOrDefault(item, 0) + 1);
        updateCart();
    }

    private void removeFromCart(String item) {
        if (cart.containsKey(item)) {
            int qty = cart.get(item) - 1;
            if (qty <= 0) {
                cart.remove(item);
            } else {
                cart.put(item, qty);
            }
            updateCart();
        }
    }

    private void updateCart() {
        cartModel.clear();
        double total = 0.0;

        for (String item : cart.keySet()) {
            int qty = cart.get(item);
            double price = menuItems.get(item);
            double subtotal = price * qty;
            cartModel.addElement(item + " x" + qty + " - $" + String.format("%.2f", subtotal));
            total += subtotal;
        }

        totalLabel.setText("Total: $" + String.format("%.2f", total));
    }

    private void checkout() {
        if (cart.isEmpty()) {
            JOptionPane.showMessageDialog(this, "Cart is empty!", "Checkout", JOptionPane.INFORMATION_MESSAGE);
        } else {
            JOptionPane.showMessageDialog(this, "Order placed successfully!", "Checkout", JOptionPane.INFORMATION_MESSAGE);
            cart.clear();
            updateCart();
        }
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(OrderingSystem::new);
    }
}
