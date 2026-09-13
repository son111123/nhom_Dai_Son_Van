
## Cập nhật Bài tập thực hành 2
- **Thành viên:** [Đinh Khắc Đại] - [24100340]
- **Đối tượng đảm nhận:** `Person` / `Student`
- **Công việc đã làm:** 
  - Viết code Dart khai báo các thuộc tính và phương thức.
  - Vẽ UML Class Diagram và Activity Diagram.
<img width="667" height="495" alt="free" src="https://github.com/user-attachments/assets/9943e2bf-9895-4ce6-918c-3dc79c0080f6" />


class Product {
  // 1. Các thuộc tính (Attributes)
  String id;
  String name;
  double price;
  int quantity;
  Product({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 0,
  });
  void displayInfo() {
    print('--- Thông tin sản phẩm ---');
    print('ID: $id');
    print('Tên: $name');
    print('Giá: \$${price.toStringAsFixed(2)}');
    print('Tồn kho: $quantity');
  }

  double calculateDiscountedPrice(double discountPercentage) {
    if (discountPercentage < 0 || discountPercentage > 100) {
      print('Lỗi: Phần trăm giảm giá không hợp lệ!');
      return price; 
    }
    
    double discountAmount = price * (discountPercentage / 100);
    double finalPrice = price - discountAmount;
    
    return finalPrice;
  }
}

void main() {
 
  Product laptop = Product(id: 'P001', name: 'MacBook Pro M3', price: 1500.0, quantity: 10);
  laptop.displayInfo();
  double salePrice = laptop.calculateDiscountedPrice(15); // Giảm 15%
  print('Giá sau khi giảm 15%: \$${salePrice.toStringAsFixed(2)}');
}
