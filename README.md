# APIManager

This Package contains easy to use AF wrapper with SSL Pinning Support.

After Import this repo using SPM, follow below steps.

Step 1: Create enum like below.

```swift
//MARK: API Endpoints
enum APIEndPoint {
    
    case Users(page : Int)
    
    static let BaseURL = EnvironmentManager.rootURL
    
    var relative: String {
        switch self {
        case .Users(let page):
            return "\(APIEndPoint.BaseURL)users?page=\(page)"
        }
    }

}

//MARK: API Header
extension APIEndPoint{
    
    enum WebHeaderKey :String {
        case Content_Type = "Content-Type"
        case Authorization = "Authorization"
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


NOTE : 
1. sslPinningType currently supports only certificate and public key pinning, if you are using certificate pinning then remember to submit new app with new ssl certificate when certificate expiries, if you are using public key pinning then make sure public key are same, else you will need to submit new app.
2. isDebugOn flag is used for dumping api request and response its default value is false
