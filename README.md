# APIManager

This Package contains easy to use AF wrapper with SSL Pinning Support.

After Import this repo using SPM, follow below steps.

Step 1: Create enum like below.

```swift
enum APIEndPoint {

    /// Keys for Headers
    enum WebHeaderKey :String {
        case Content_Type = "Content-Type"
        case Authorization = "Authorization"
    }
   
    static let BaseURL = EnvironmentManager.rootURL
    
    case Users(page : Int)
    
    var relative: String {
        switch self {
        case .Users(let page):
            return "\(APIEndPoint.BaseURL)users?page=\(page)"
        }
    }
    
    var header : [String:String]? {
        switch self {
        case .Users(_):
            return [WebHeaderKey.Authorization.rawValue: "Bearer TOKEN", WebHeaderKey.Content_Type.rawValue:"application/json"]
        }
    }
      
}
```

Step 2: Create Service File with Below Func

```swift
func CallUserAPI(_ page : Int,completion: @escaping (Result<UsersModel,Error>) -> ()) {

    let endpoint = APIEndPoint.Users(page: page)
    
    APIManager(sslPinningType: .PublicKey, isDebugOn: EnvironmentManager.isDebugOn).APIRequest(endpoint.relative, httpMethod: .GET, header: endpoint.header, completion: completion)
    
}
```

Step 3: In ViewModel call this service file func, **Use weak self to avoid retainng memory.**

```swift
UsersAPI().CallUserAPI(page) { result in
    switch result{
        case .success(let value):
            self.ParseUsersAPI(value)
        case .failure(let error):
        break
    }
}
```

NOTE : sslPinningType currently supports only certificate and public key pinning, isDebugOn flag is used for dumping api request and response its default value is false
