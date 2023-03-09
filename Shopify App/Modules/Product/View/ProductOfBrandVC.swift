//
//  ProductOfBrandVC.swift
//  Shopify App
//  Created by Ali Moustafa on 02/03/2023.

import UIKit
import Alamofire
import Kingfisher

class ProductOfBrandVC: UIViewController {
    
//    @IBOutlet weak var vendorName: UILabel!
    @IBOutlet weak var ProductOfBrandsCollection: UICollectionView!
    var productOBbrandsModel : ProductOfBrand?     //variable to response data
    var filteredProducts : [ProductOfBrands]? = [ProductOfBrands]()
    var  searchedProducts  = [ProductOfBrands]()
    var isFavorite: Bool = false
    var SmartCollectionID: String = ""
    var isFiltered = false //for slider
    var filterIsPressed = true
    var isFiltering : Bool = false
    
    @IBOutlet weak var productSearchBar: UISearchBar!
    
    @IBOutlet weak var priceSlider: UISlider!
    @IBOutlet weak var minimumPrice: UILabel!
    
    @IBOutlet weak var maximumPrice: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        registerBrandCollectionView()
        
       productSearchBar.delegate = self
        
        
        //fetch data
        fetchData { result in
            DispatchQueue.main.async {
                self.productOBbrandsModel = result
                self.title = self.productOBbrandsModel?.products.first?.vendor
                self.filteredProducts = result?.products
              
                self.ProductOfBrandsCollection.reloadData()
            }
        }
        //
        
        //slider
        maximumPrice.isHidden = true
        minimumPrice.isHidden = true
        priceSlider.isHidden = true
//        notFoundImage.isHidden = true
//        setupProductCollection()
        //slider
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.ProductOfBrandsCollection.reloadData()
    }
    
    
    @IBAction func filterSlider(_ sender: UISlider) {
        
        print(sender.value)
        isFiltered = true
        let filteredByPrice = self.productOBbrandsModel?.products.filter { product in
            maximumPrice.text = "$"+String(Int(sender.value))
            return Float(product.variants[0].price ) ?? 0 <= sender.value
        }
            self.filteredProducts = filteredByPrice
        self.updateUi()
    }
    
    
    private func updateUi(){
        DispatchQueue.main.async {
        self.ProductOfBrandsCollection.reloadData()
        }
    }
    
    
    
    @IBAction func filterButtonByPrice(_ sender: UIButton) {
        filterBtnIsPressed()

    }
    
    private func filterBtnIsPressed(){
        if filterIsPressed{
            filterIsPressed = false
            minimumPrice.isHidden = false
            maximumPrice.isHidden = false
            priceSlider.isHidden = false
        }else{
            minimumPrice.isHidden = true
            maximumPrice.isHidden = true
            filterIsPressed = true
            priceSlider.isHidden = true
        }
    }
    
    
    @IBAction func toWishlistButton(_ sender: Any) {
        
    let userDefaultToken = UserDefaults.standard.integer(forKey: "loginId")

        if userDefaultToken != 0 {
            var wishListVC = self.storyboard?.instantiateViewController(withIdentifier: "FavouriteVC") as! FavouriteVC
            self.navigationController?.pushViewController(wishListVC, animated: true)
            
        }else{
            var loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginViewController") as! loginViewController
            self.navigationController?.pushViewController(loginVC, animated: true)
            
        }
        

    }
    
    @IBAction func toCartButton(_ sender: Any) {
        let storyboard =  UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "SingUpViewController")
        viewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewController, animated: true)
        print("toCartButton")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)

    }
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func  registerBrandCollectionView(){
        
        ProductOfBrandsCollection.register(UINib(nibName: "ProductOFBrandCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductOFBrandCollectionViewCell")
        ProductOfBrandsCollection.delegate = self
        ProductOfBrandsCollection.dataSource = self
        
      
    }
    
   
}


extension ProductOfBrandVC : UISearchBarDelegate{
    var isSearchBarEmpty : Bool {
        return productSearchBar.text!.isEmpty
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        if !searchText.isEmpty {
            isFiltering = true
        }
      searchedProducts =  productOBbrandsModel?.products.filter({ product in
            return product.title.lowercased().contains(searchText.lowercased())
      }) ?? []
        
        // reload table
        self.ProductOfBrandsCollection.reloadData()
        if isSearchBarEmpty {
            isFiltering = false
            self.ProductOfBrandsCollection.reloadData()
        }
    }
}


extension ProductOfBrandVC: CollectionView_Delegate_DataSource_FlowLayout{
    

    //    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    //        let storyboard =  UIStoryboard(name: "Main", bundle: nil)
    //        let viewController = storyboard.instantiateViewController(withIdentifier: "SingUpViewController")
    //        navigationController?.pushViewController(viewController, animated: true)
    //    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if isFiltering {
            return searchedProducts.count
            
        }
      return  filteredProducts?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductOFBrandCollectionViewCell", for: indexPath) as! ProductOFBrandCollectionViewCell
       
        var productKey = "\((filteredProducts?[indexPath.row].id)!)"
        print(productKey)
        if UserDefaults.standard.bool(forKey: productKey){
            cell.favButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            print("add Fav")
          }else{
              cell.favButton.setImage(UIImage(systemName: "heart"), for: .normal)
                print("not fav")
        }
        
        
        cell.addToWishList = { [unowned self] in
            var favIsSelected =  UserDefaults.standard.bool(forKey: productKey)

               cell.favButton.isSelected =   UserDefaults.standard.bool(forKey: productKey)
         
            cell.favButton.isSelected = !cell.favButton.isSelected
            
            if  cell.favButton.isSelected {
                
             cell.favButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            // save to core data
            CoreDataManager.saveProductToCoreData(productName:filteredProducts?[indexPath.row].title ?? ""      , productPrice: filteredProducts?[indexPath.row].variants.first?.price ?? "", productImage:        filteredProducts?[indexPath.row].image.src ?? "", productId: filteredProducts?[indexPath.row].id ?? 0)
                
            UserDefaults.standard.set(true, forKey: "\(filteredProducts?[indexPath.row].id ?? 0)")

            }else{
                
                cell.favButton.setImage(UIImage(systemName: "heart"), for: .normal)
                CoreDataManager.deleteFromCoreData(productName: filteredProducts?[indexPath.row].title ?? "" )
                UserDefaults.standard.set(false, forKey: "\(filteredProducts?[indexPath.row].id ?? 0)")
            }
    }

        
        
        
        
//        
//        self.productListCollectionView.isHidden = false
//        cell.productNameLabel.text = filteredProducts[indexPath.row].title
//        cell.productImageView.kf.setImage(with:URL(string:filteredProducts[indexPath.row].image?.src ?? ""))
//        cell.productImageView.kf.indicatorType = .activity
//        if  let variant = filteredProducts[indexPath.row].variants, let price = variant[0].price {
//            cell.productPriceLabel.text = "$"+price
//        }
//    return cell
        
        if isFiltering {
//
            cell.nameOfProductBrand.text = searchedProducts[indexPath.row].title
                cell.ProductType.text = searchedProducts[indexPath.row].productType
                if let firstPrice = searchedProducts[indexPath.row].variants.first?.price {
                    cell.productPrice.text = "$\(firstPrice)"
                } else {
                    cell.productPrice.text = ""
                }
                
                if let imageUrl = URL(string: searchedProducts[indexPath.row].image.src) {
                           cell.productImage.kf.setImage(with: imageUrl)

                }

            
        } else{
            
            if let productOfbrand = filteredProducts?[indexPath.row] {
                cell.nameOfProductBrand.text = productOfbrand.title
                cell.ProductType.text = productOfbrand.productType
                if let firstPrice = productOfbrand.variants.first?.price {
                    cell.productPrice.text = "$\(firstPrice)"
                } else {
                    cell.productPrice.text = ""
                }
                
                if let imageUrl = URL(string: productOfbrand.image.src) {
                           cell.productImage.kf.setImage(with: imageUrl)

                       }
                   }
        }
        
        
        return cell
        
    }
    
}


extension ProductOfBrandVC{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
                let width = collectionView.frame.width
                return CGSize(width: width / 2, height: 236)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    
    
    
}



extension ProductOfBrandVC{
    func fetchData(compilation: @escaping (ProductOfBrand?) -> Void)
    {
   
        guard let url = URL(string: "https://b24cfe7f0d5cba8ddb793790aaefa12a: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@mad-ios-2.myshopify.com/admin/api/2023-01/products.json?collection_id=\(SmartCollectionID)") else {return}
        
        AF.request(url).response
        { response in
            if let data = response.data {
                do{
                    
                    let result = try JSONDecoder().decode(ProductOfBrand.self, from: data)
                    
                    compilation(result)
                }
                catch{
                    compilation(nil)
                }
            } else {
                compilation(nil)
            }
        }
    }
    
    
}



//
//extension ProductOfBrandVC{
//    func checkIsProductSelected(row: Int, sender: UIButton){
//        if !sender.isSelected {
//             //button selected
//            sender.isSelected = true
//            sender.setImage(UIImage(systemName: "heart.fill"), for: .normal)
//            self.addToWishList(row: row)
//         }
//         else{
//             //button non selected
//             sender.isSelected = false
//             sender.setImage(UIImage(systemName: "heart"), for: .normal)
//             self.nonSelectedProduct(row: row)
//         }
//    }
//}



