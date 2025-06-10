export default class User {
    constructor(
        id,
        fcmToken,
    ) {
        this.id = id;
        this.fcmToken = fcmToken;
    }

    static fromJson(json) {
        return new User(
            json.id,
            json.fcmToken,
        );
    }

    toJson() {
        return {
            id: this.id,
            fcmToken: this.fcmToken,
        };
    }
}