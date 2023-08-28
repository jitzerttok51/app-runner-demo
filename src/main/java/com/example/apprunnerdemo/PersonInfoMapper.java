package com.example.apprunnerdemo;

import org.springframework.stereotype.Component;

@Component
public class PersonInfoMapper {

    public PersonInfo toEntity(PersonInfoDTO dto) {
        return new PersonInfo(dto.getId(), dto.getName(), dto.getAge());
    }

    public PersonInfoDTO toDTO(PersonInfo e) {
        return new PersonInfoDTO(e.getId(), e.getName(), e.getAge());
    }
}
