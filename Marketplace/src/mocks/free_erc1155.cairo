use starknet::ContractAddress;

//mock erc20
#[starknet::interface]
pub trait IFreeMintERC1155<T> {
    fn mint(ref self: T, recipient: ContractAddress, token_id: u256, amount: u256);
}

#[starknet::contract]
mod FreeMintERC1155 {
    use super::IFreeMintERC1155;

    use openzeppelin_introspection::src5::SRC5Component;
    use openzeppelin_token::erc1155::{ERC1155Component, ERC1155HooksEmptyImpl};
    use starknet::ContractAddress;

    component!(path: ERC1155Component, storage: erc1155, event: ERC1155Event);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);

    // ERC1155
    #[abi(embed_v0)]
    impl ERC1155Impl = ERC1155Component::ERC1155Impl<ContractState>;
    #[abi(embed_v0)]
    impl ERC1155MetadataURIImpl =
        ERC1155Component::ERC1155MetadataURIImpl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721Camel = ERC1155Component::ERC1155CamelImpl<ContractState>;
    impl ERC1155InternalImpl = ERC1155Component::InternalImpl<ContractState>;

    // SRC5
    #[abi(embed_v0)]
    impl SRC5Impl = SRC5Component::SRC5Impl<ContractState>;

    #[storage]
    pub struct Storage {
        #[substorage(v0)]
        pub erc1155: ERC1155Component::Storage,
        #[substorage(v0)]
        pub src5: SRC5Component::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC1155Event: ERC1155Component::Event,
        #[flat]
        SRC5Event: SRC5Component::Event,
    }

    #[constructor]
    fn constructor(ref self: ContractState, base_uri: ByteArray) {
        self.erc1155.initializer(base_uri);
    }


    #[abi(embed_v0)]
    impl ImplFreeMint of IFreeMintERC1155<ContractState> {
        fn mint(ref self: ContractState, recipient: ContractAddress, token_id: u256, amount: u256) {
            self.erc1155.mint_with_acceptance_check(recipient, token_id, amount, array![].span());
        }
    }
}
