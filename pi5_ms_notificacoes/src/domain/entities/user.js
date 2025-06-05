export default class User {
    constructor(
        jcmToken,
    ) {
        this.jcmToken = jcmToken;
    }

    static fromJson(json) {
        return new User(
            json.jcmToken,
        );
    }

    toJson() {
        return {
            jcmToken: this.jcmToken,
        };
    }
}