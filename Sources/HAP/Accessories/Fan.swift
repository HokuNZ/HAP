extension Accessory {
    open class Fan: Accessory {
        public let fan = Service.Fan()

        public init(info: Service.Info) {
            super.init(info: info, type: .fan, services: [fan])
        }
    }
}

extension Service {
    public class Fan: Service {
        open let on = GenericCharacteristic<On>(type: .on, value: false)

        public init() {
            super.init(type: .fan, characteristics: [on])
        }
    }
}
