import { Transaction } from "@mysten/sui/transactions";

// DİKKAT: Fonksiyonu değiştirdik, artık packageId istemiyor, biz içeride veriyoruz.
export const transferHero = (heroId: string, to: string) => {
  const tx = new Transaction();
  
  // Senin son oluşturduğun Package ID buraya:
  const PACKAGE_ID = "0xe0572d77c1887cd97cd4f645d78d2afd77ff0de99914dd412ac9295ed182ba99";

  tx.moveCall({
    target: `${PACKAGE_ID}::hero::transfer_hero`,
    arguments: [
      tx.object(heroId),
      tx.pure.address(to),
    ],
  });

  return tx;
};