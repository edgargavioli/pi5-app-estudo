export class Notification {
    constructor(
        userId,
        type,
        title,
        content,
    ) {
        this.userId = userId;
        this.type = type;
        this.title = title;
        this.content = content;
    }

    static fromJson(json) {
        return new Notification(
            json.userId,
            json.type,
            json.title,
            json.content,
        );
    }

    toJson() {
        return {
            userId: this.userId,
            type: this.type,
            title: this.title,
            content: this.content,
        };
    }
}