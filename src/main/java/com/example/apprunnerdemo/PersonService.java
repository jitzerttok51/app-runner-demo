package com.example.apprunnerdemo;

import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@Service
public class PersonService {

    private final BasicRepository repository;

    private final PersonInfoMapper mapper;

    public PersonService(BasicRepository repository, PersonInfoMapper mapper) {
        this.repository = repository;
        this.mapper = mapper;
    }

    public Flux<PersonInfoDTO> getAllPeople() {
        return repository.findAll().map(mapper::toDTO);
    }

    public Mono<PersonInfoDTO> getPerson(String id) {
        return repository.findById(id).map(mapper::toDTO).switchIfEmpty(Mono.empty());
    }

    public Mono<PersonInfoDTO> createPerson(PersonInfoDTO p) {
        return Mono
                   .just(p)
                   .map(mapper::toEntity)
                   .flatMap(repository::save)
                   .map(mapper::toDTO);
    }
}
