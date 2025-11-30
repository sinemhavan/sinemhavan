module challenge::hero {
    use std::string::String;

    public struct Hero has key, store {
        id: UID,
        name: String,
        image_url: String,
        power: u64,
    }

    public struct HeroMetadata has key, store {
        id: UID,
        timestamp: u64,
    }

    #[allow(lint(self_transfer))]
    public entry fun create_hero(name: String, image_url: String, power: u64, ctx: &mut TxContext) {
        let hero = Hero {
            id: object::new(ctx),
            name,
            image_url,
            power,
        };

        let hero_metadata = HeroMetadata {
            id: object::new(ctx),
            timestamp: tx_context::epoch_timestamp_ms(ctx),
        };

        transfer::public_transfer(hero, tx_context::sender(ctx));
        transfer::freeze_object(hero_metadata);
    }

    public entry fun transfer_hero(hero: Hero, to: address) {
        transfer::public_transfer(hero, to);
    }

    // ========= GETTER FUNCTIONS =========
    public fun hero_power(hero: &Hero): u64 { hero.power }
    
    #[test_only]
    public fun hero_name(hero: &Hero): String { hero.name }

    #[test_only]
    public fun hero_image_url(hero: &Hero): String { hero.image_url }

    #[test_only]
    public fun hero_id(hero: &Hero): ID { object::id(hero) }
}