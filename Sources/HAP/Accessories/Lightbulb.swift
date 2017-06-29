extension Accessory {
    open class Lightbulb: Accessory {
        public let lightbulb = Service.Lightbulb()

        public init(info: Service.Info) {
            super.init(info: info, type: .lightbulb, services: [lightbulb])
        }
    }

    open class SimpleLightbulb: Accessory {
        public let lightbulb = Service.SimpleLightbulb()

        public init(info: Service.Info) {
            super.init(info: info, type: .lightbulb, services: [lightbulb])
        }
    }

    open class DimmableLightbulb: Accessory {
        public let lightbulb = Service.DimmableLightbulb()

        public init(info: Service.Info) {
            super.init(info: info, type: .lightbulb, services: [lightbulb])
        }
    }
}

public typealias On = Bool
public typealias Brightness = Int
public typealias Saturation = Int
public typealias Hue = Int

extension Service {
    open class Lightbulb: Service {
        public let on = GenericCharacteristic<On>(type: .on, value: false)
        public let brightness = GenericCharacteristic<Brightness>(type: .brightness, value: 100, unit: .percentage, maxValue: 100, minValue: 0, minStep: 1)
        public let saturation = GenericCharacteristic<Saturation>(type: .saturation, value: 0, unit: .percentage, maxValue: 100, minValue: 0, minStep: 1)
        public let hue = GenericCharacteristic<Hue>(type: .hue, value: 0, unit: .arcdegrees, maxValue: 360, minValue: 0, minStep: 1)

        public init() {
            super.init(type: .lightbulb, characteristics: [on, brightness, saturation, hue])
        }
    }

    open class SimpleLightbulb: Service {
        public let on = GenericCharacteristic<On>(type: .on, value: false)

        public init() {
            super.init(type: .lightbulb, characteristics: [on])
        }
    }

    open class DimmableLightbulb: Service {
        public let on = GenericCharacteristic<On>(type: .on, value: false)
        public let brightness = GenericCharacteristic<Brightness>(type: .brightness, value: 100, unit: .percentage, maxValue: 100, minValue: 0, minStep: 1)

        public init() {
            super.init(type: .lightbulb, characteristics: [on, brightness])
        }
    }
}
