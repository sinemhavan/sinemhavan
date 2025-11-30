
module challenge::arena {
    use challenge::hero::{Self, Hero};
    use sui::event;

    public struct Arena has key, store {
        id: UID,
        warrior: Hero,
        owner: address,
    }

    public struct ArenaCreated has copy, drop {
        arena_id: ID,
        timestamp: u64,
    }

    public struct ArenaCompleted has copy, drop {
        winner_hero_id: ID,
        loser_hero_id: ID,
        timestamp: u64,
    }

    public fun create_arena(hero: Hero, ctx: &mut TxContext) {
        let id = object::new(ctx);
        
        event::emit(ArenaCreated {
            arena_id: object::uid_to_inner(&id),
            timestamp: tx_context::epoch_timestamp_ms(ctx),
        });

        let arena = Arena {
            id,
            warrior: hero,
            owner: tx_context::sender(ctx),
        };
        transfer::share_object(arena);
    }

    #[allow(lint(self_transfer))]
    public fun battle(hero: Hero, arena: Arena, ctx: &mut TxContext) {
        let Arena { id, warrior, owner } = arena;
        
        if (hero::hero_power(&hero) > hero::hero_power(&warrior)) {
            event::emit(ArenaCompleted {
                winner_hero_id: object::id(&hero),
                loser_hero_id: object::id(&warrior),
                timestamp: tx_context::epoch_timestamp_ms(ctx)
            });
            transfer::public_transfer(hero, tx_context::sender(ctx));
            transfer::public_transfer(warrior, tx_context::sender(ctx));
        } else {
            event::emit(ArenaCompleted {
                winner_hero_id: object::id(&warrior),
                loser_hero_id: object::id(&hero),
                timestamp: tx_context::epoch_timestamp_ms(ctx)
            });
            transfer::public_transfer(hero, owner);
            transfer::public_transfer(warrior, owner);
        };
        object::delete(id);
    }
}
