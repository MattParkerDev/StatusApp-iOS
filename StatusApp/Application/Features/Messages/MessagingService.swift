
import Foundation

class MessagingService {
    let _messagesClient: IMessagingClient;
    
    init() {
        _messagesClient = MessagingClient();
    }
    
    
    func GetMessages(GroupId: UUID) async -> [Message] {
        let messages = await _messagesClient.GetMessagesAsync(GroupId: GroupId);

        return messages;
    }
}
