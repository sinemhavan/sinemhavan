module challenge::marketplace {
    use challenge::hero::Hero;
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::event;

    const EInvalidPayment: u64 = 1;

    public struct ListHero has key, store {
        id: UID,
        nft: Hero,
        price: u64,
        seller: address,
    }

    public struct AdminCap has key, store { id: UID }

    public struct HeroListed has copy, drop {
        list_hero_id: ID,
        price: u64,
        seller: address,
        timestamp: u64,
    }

    public struct HeroBought has copy, drop {
        list_hero_id: ID,
        price: u64,
        buyer: address,
        seller: address,
        timestamp: u64,
    }

    fun init(ctx: &mut TxContext) {
        let admin_cap = AdminCap { id: object::new(ctx) };
        transfer::transfer(admin_cap, tx_context::sender(ctx));
    }

    public fun list_hero(nft: Hero, price: u64, ctx: &mut TxContext) {
        let id = object::new(ctx);
        let seller = tx_context::sender(ctx);

        event::emit(HeroListed {
            list_hero_id: object::uid_to_inner(&id),
            price,
            seller,
            timestamp: tx_context::epoch_timestamp_ms(ctx)
        });

        let list_hero = ListHero { id, nft, price, seller };
        transfer::share_object(list_hero);
    }

    #[allow(lint(self_transfer))]
    public fun buy_hero(list_hero: ListHero, coin: Coin<SUI>, ctx: &mut TxContext) {
        let ListHero { id, nft, price, seller } = list_hero;
        assert!(coin::value(&coin) == price, EInvalidPayment);

        event::emit(HeroBought {
            list_hero_id: object::uid_to_inner(&id),
            price,
            buyer: tx_context::sender(ctx),
            seller,
            timestamp: tx_context::epoch_timestamp_ms(ctx)
        });

        transfer::public_transfer(coin, seller);
        transfer::public_transfer(nft, tx_context::sender(ctx));
        object::delete(id);
    }

    public fun delist(_: &AdminCap, list_hero: ListHero) {
        let ListHero { id, nft, price: _, seller } = list_hero;
        transfer::public_transfer(nft, seller);
        object::delete(id);
    }

    public fun change_the_price(_: &AdminCap, list_hero: &mut ListHero, new_price: u64) {
        list_hero.price = new_price;
    }

    #[test_only]
    public fun listing_price(list_hero: &ListHero): u64 { list_hero.price }
    
    #[test_only]
    public fun test_init(ctx: &mut TxContext) {
        init(ctx);
    }
}

