package com.example.apprunnerdemo;

import org.springframework.data.mongodb.repository.Query;
import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Mono;

@Repository
public interface BasicRepository extends ReactiveCrudRepository<PersonInfo, String> {

    @Query("{age: ?0}")
    Mono<PersonInfo> findByAge(int age);
}
