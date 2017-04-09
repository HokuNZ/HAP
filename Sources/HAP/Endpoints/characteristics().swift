import Foundation
import HKDF
import func Evergreen.getLogger

fileprivate let logger = getLogger("hap")

func characteristics(device: Device) -> Application {
    return { (connection, request) in
        switch request.method {
        case "GET":
            guard
                let id = request.urlComponents.queryItems?.first(where: {$0.name == "id"})?.value
                else {
                    return .badRequest
            }

            let paths = id.components(separatedBy: ",").map { $0.components(separatedBy: ".").flatMap { Int($0) } }

            var serialized: [[String: Any]] = []
            for path in paths {
                guard path.count == 2 else {
                    return .badRequest
                }
                guard
                    let characteristic = device.accessories.first(where: {$0.aid == path[0]})?.services.flatMap({$0.characteristics.filter({$0.iid == path[1]})}).first
                    else {
                        // @fixme: hc sets status to StatusServiceCommunicationFailure instead
                        return .notFound
                }
                serialized.append([
                    "aid": path[0],
                    "iid": path[1],
                    "value": characteristic.valueAsAny ?? NSNull()
                ])
            }

            let json = try! JSONSerialization.data(withJSONObject: ["characteristics": serialized], options: [])
            return Response(data: json, mimeType: "application/hap+json")

        case "PUT":
            var body = Data()
            guard let _  = try? request.readAllData(into: &body),
                let deserialized = try? JSONSerialization.jsonObject(with: body, options: []),
                let dict = deserialized as? [String: [[String: Any]]],
                let items = dict["characteristics"] else
            {
                logger.warning("Could not decode JSON")
                return .badRequest
            }

            for item in items {
                print(item)
                guard let aid = item["aid"] as? Int,
                    let iid = item["iid"] as? Int else
                {
                    logger.warning("Missing either aid/iid keys")
                    return .badRequest
                }
                guard let characteristic = device.accessories
                    .first(where: {$0.aid == aid})?
                    .services
                    .flatMap({$0.characteristics.filter({$0.iid == iid})})
                    .first else
                {
                    return .notFound
                }

                // set new value
                if let value = item["value"] {
                    do {
                        logger.debug("Setting \(characteristic) to new value \(value) (type: \(type(of: value)))")
                        switch value {
                        case let value as Int: try characteristic.setValue(value, fromConnection: connection)
                        case let value as Double: try characteristic.setValue(value, fromConnection: connection)
                        case let value as String: try characteristic.setValue(value, fromConnection: connection)
                        case is NSNull: try characteristic.setValue(nil, fromConnection: connection)
                        default:
                            logger.error("Unexpected new value type: \(type(of: value))")
                            return .badRequest
                        }
                    } catch {
                        logger.error("Error while trying to set new value: \(error)")
                        return .badRequest
                    }

                    // notify listeners
                    device.notify(characteristicListeners: characteristic, exceptListener: connection)
                }

                // toggle events for this characteristic on this connection
                if let events = (item["ev"] as? NSNumber).flatMap({$0.boolValue}) {
                    if events {
                        device.add(characteristic: characteristic, listener: connection)
                        logger.info("Added listener for \(characteristic)")
                    } else {
                        device.remove(characteristic: characteristic, listener: connection)
                        logger.info("Removed listener for \(characteristic)")
                    }
                }
            }

            return Response(status: .noContent)

        default:
            return .badRequest
        }
    }
}
